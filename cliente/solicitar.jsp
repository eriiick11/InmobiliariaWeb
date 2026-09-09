<%--
  cliente/solicitar.jsp - Controlador (solo POST) para que un CLIENTE
  radique una solicitud de COMPRA o ARRIENDO sobre una propiedad.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String tipo = request.getParameter("tipo"); // COMPRA | ARRIENDO
    String destinoFicha = ctx + "/propiedades/ficha.jsp?id=" + idPropiedad;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        if (idPropiedad <= 0 || (!"COMPRA".equals(tipo) && !"ARRIENDO".equals(tipo))) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("Selecciona un tipo de tramite valido.", "UTF-8"));
            return;
        }

        con = abrirConexion();

        // La propiedad debe existir y estar disponible
        ps = con.prepareStatement("SELECT estado FROM propiedad WHERE id_propiedad = ?");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        boolean disponible = rs.next() && "DISPONIBLE".equals(rs.getString("estado"));
        cerrar(rs, ps);

        if (!disponible) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("Esta propiedad ya no admite solicitudes.", "UTF-8"));
            return;
        }

        // Evita que el mismo cliente radique dos solicitudes pendientes del
        // mismo tipo sobre la misma propiedad (regla de negocio, no UNIQUE de BD)
        ps = con.prepareStatement(
            "SELECT COUNT(*) AS n FROM solicitud "
          + "WHERE id_propiedad = ? AND id_cliente = ? AND tipo = ? AND estado = 'PENDIENTE'");
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuarioSesion);
        ps.setString(3, tipo);
        rs = ps.executeQuery();
        rs.next();
        boolean yaTienePendiente = rs.getInt("n") > 0;
        cerrar(rs, ps);

        if (yaTienePendiente) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("Ya tienes una solicitud pendiente de ese tipo sobre esta propiedad.", "UTF-8"));
            return;
        }

        ps = con.prepareStatement(
            "INSERT INTO solicitud (id_propiedad, id_cliente, tipo, estado) VALUES (?, ?, ?, 'PENDIENTE')");
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuarioSesion);
        ps.setString(3, tipo);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(ctx + "/cliente/mis_solicitudes.jsp?msg="
            + java.net.URLEncoder.encode("Solicitud radicada. Ya puedes subir tus documentos.", "UTF-8"));

    } catch (SQLException ex) {
        response.sendRedirect(destinoFicha + "&err="
            + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
