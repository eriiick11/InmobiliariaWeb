<%--
  inmobiliaria/guardar_propiedad.jsp - Controlador de alta/edicion de
  propiedad. No genera HTML: siempre redirige.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    boolean esEdicion = idPropiedad > 0;

    String matricula   = request.getParameter("matricula_inmobiliaria");
    String titulo       = request.getParameter("titulo");
    String descripcion  = request.getParameter("descripcion");
    String direccion    = request.getParameter("direccion");
    String estado        = request.getParameter("estado");
    int idTipo   = aEntero(request.getParameter("id_tipo_propiedad"), 0);
    int idCiudad = aEntero(request.getParameter("id_ciudad"), 0);
    double precio = aDoble(request.getParameter("precio"), 0);
    double area   = aDoble(request.getParameter("area"), 0);

    String destino;
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        // 1) Averiguar id_inmobiliaria del usuario en sesion
        int idInmobiliaria = 0;
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        if (idInmobiliaria == 0) {
            response.sendRedirect(ctx + "/acceso-denegado.jsp");
            return;
        }

        // 2) Validaciones minimas de campos obligatorios
        if (matricula == null || matricula.trim().isEmpty()
            || titulo == null || titulo.trim().isEmpty()
            || idTipo == 0 || idCiudad == 0 || precio <= 0) {
            destino = ctx + "/inmobiliaria/propiedad_form.jsp"
                + (esEdicion ? "?id=" + idPropiedad : "")
                + (esEdicion ? "&" : "?")
                + "err=" + java.net.URLEncoder.encode(
                    "Completa matricula, titulo, tipo, ciudad y un precio valido.", "UTF-8");
            response.sendRedirect(destino);
            return;
        }

        con.setAutoCommit(false);

        if (esEdicion) {
            // 3a) Verificar que la propiedad pertenezca a esta inmobiliaria
            ps = con.prepareStatement("SELECT id_inmobiliaria FROM propiedad WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            rs = ps.executeQuery();
            boolean esDueño = rs.next() && rs.getInt("id_inmobiliaria") == idInmobiliaria;
            cerrar(rs, ps);
            if (!esDueño) {
                deshacer(con);
                response.sendRedirect(ctx + "/acceso-denegado.jsp");
                return;
            }

            ps = con.prepareStatement(
                "UPDATE propiedad SET matricula_inmobiliaria = ?, id_tipo_propiedad = ?, "
              + "  id_ciudad = ?, titulo = ?, descripcion = ?, precio = ?, area = ?, "
              + "  direccion = ?, estado = ? "
              + "WHERE id_propiedad = ?");
            ps.setString(1, matricula.trim());
            ps.setInt(2, idTipo);
            ps.setInt(3, idCiudad);
            ps.setString(4, titulo.trim());
            ps.setString(5, descripcion);
            ps.setDouble(6, precio);
            ps.setDouble(7, area);
            ps.setString(8, direccion);
            ps.setString(9, (estado == null || estado.isEmpty()) ? "DISPONIBLE" : estado);
            ps.setInt(10, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);

            con.commit();
            destino = ctx + "/inmobiliaria/propiedad_form.jsp?id=" + idPropiedad
                + "&msg=" + java.net.URLEncoder.encode("Propiedad actualizada.", "UTF-8");

        } else {
            // 3b) Insertar propiedad nueva (siempre arranca DISPONIBLE)
            ps = con.prepareStatement(
                "INSERT INTO propiedad (matricula_inmobiliaria, id_inmobiliaria, id_tipo_propiedad, "
              + "  id_ciudad, titulo, descripcion, precio, area, direccion, estado) "
              + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'DISPONIBLE')",
                Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, matricula.trim());
            ps.setInt(2, idInmobiliaria);
            ps.setInt(3, idTipo);
            ps.setInt(4, idCiudad);
            ps.setString(5, titulo.trim());
            ps.setString(6, descripcion);
            ps.setDouble(7, precio);
            ps.setDouble(8, area);
            ps.setString(9, direccion);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            rs.next();
            int nuevoId = rs.getInt(1);
            cerrar(rs, ps);

            con.commit();
            destino = ctx + "/inmobiliaria/propiedad_form.jsp?id=" + nuevoId
                + "&msg=" + java.net.URLEncoder.encode(
                    "Propiedad creada. Ahora puedes agregarle imagenes y caracteristicas.", "UTF-8");
        }

    } catch (SQLIntegrityConstraintViolationException ex) {
        deshacer(con);
        destino = ctx + "/inmobiliaria/propiedad_form.jsp"
            + (esEdicion ? "?id=" + idPropiedad : "")
            + (esEdicion ? "&" : "?")
            + "err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } catch (SQLException ex) {
        deshacer(con);
        destino = ctx + "/inmobiliaria/propiedad_form.jsp"
            + (esEdicion ? "?id=" + idPropiedad : "")
            + (esEdicion ? "&" : "?")
            + "err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
