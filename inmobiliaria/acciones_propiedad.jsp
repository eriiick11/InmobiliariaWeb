<%--
  inmobiliaria/acciones_propiedad.jsp - Controlador de acciones puntuales
  sobre una propiedad ya existente: agregar/quitar imagen, marcar/desmarcar
  una caracteristica, y baja/reactivacion logica.
  Todas las acciones verifican que la propiedad pertenezca a la
  inmobiliaria en sesion antes de modificar nada.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String destino = ctx + "/inmobiliaria/propiedad_form.jsp?id=" + idPropiedad;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        // ---------- Verificacion de propiedad: la propiedad debe ser de esta inmobiliaria ----------
        int idInmobiliaria = 0;
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        ps = con.prepareStatement("SELECT id_inmobiliaria FROM propiedad WHERE id_propiedad = ?");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        boolean esDueÃ±o = rs.next() && rs.getInt("id_inmobiliaria") == idInmobiliaria;
        cerrar(rs, ps);

        if (!esDueÃ±o) {
            response.sendRedirect(ctx + "/acceso-denegado.jsp");
            return;
        }

        con.setAutoCommit(false);

        // ========== AGREGAR IMAGEN ==========
        if ("agregar_imagen".equals(accion)) {
            String url = request.getParameter("url_imagen");
            int orden = aEntero(request.getParameter("orden"), 1);
            ps = con.prepareStatement(
                "INSERT INTO imagen_propiedad (id_propiedad, url_imagen, orden) VALUES (?, ?, ?)");
            ps.setInt(1, idPropiedad);
            ps.setString(2, url);
            ps.setInt(3, orden);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();

        // ========== QUITAR IMAGEN ==========
        } else if ("quitar_imagen".equals(accion)) {
            int idImagen = aEntero(request.getParameter("id_imagen"), 0);
            ps = con.prepareStatement(
                "DELETE FROM imagen_propiedad WHERE id_imagen = ? AND id_propiedad = ?");
            ps.setInt(1, idImagen);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();

        // ========== TOGGLE CARACTERISTICA (marcar / desmarcar) ==========
        } else if ("toggle_caracteristica".equals(accion)) {
            int idCaracteristica = aEntero(request.getParameter("id_caracteristica"), 0);
            boolean estabaAsignada = "true".equals(request.getParameter("estaba_asignada"));

            if (estabaAsignada) {
                // Ya estaba marcada -> se desmarca (se quita el vinculo N:M)
                ps = con.prepareStatement(
                    "DELETE FROM propiedad_caracteristica "
                  + "WHERE id_propiedad = ? AND id_caracteristica = ?");
                ps.setInt(1, idPropiedad);
                ps.setInt(2, idCaracteristica);
                ps.executeUpdate();
                cerrar(ps);
            } else {
                // No estaba marcada -> se agrega el vinculo N:M
                ps = con.prepareStatement(
                    "INSERT INTO propiedad_caracteristica (id_propiedad, id_caracteristica, cantidad) "
                  + "VALUES (?, ?, 1)");
                ps.setInt(1, idPropiedad);
                ps.setInt(2, idCaracteristica);
                ps.executeUpdate();
                cerrar(ps);
            }
            con.commit();

        // ========== BAJA LOGICA ==========
        } else if ("baja".equals(accion)) {
            ps = con.prepareStatement("UPDATE propiedad SET estado = 'INACTIVO' WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                + java.net.URLEncoder.encode("Propiedad dada de baja.", "UTF-8");

        // ========== REACTIVAR ==========
        } else if ("reactivar".equals(accion)) {
            ps = con.prepareStatement("UPDATE propiedad SET estado = 'DISPONIBLE' WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino = ctx + "/inmobiliaria/propiedades.jsp?msg="
                + java.net.URLEncoder.encode("Propiedad reactivada.", "UTF-8");
        }

    } catch (SQLIntegrityConstraintViolationException ex) {
        deshacer(con);
        destino += "&err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } catch (SQLException ex) {
        deshacer(con);
        destino += "&err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
