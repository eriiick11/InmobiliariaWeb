<%-- cliente/cancelar_solicitud.jsp - Cancela (rechaza) una solicitud propia PENDIENTE. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
    String destino = ctx + "/cliente/mis_solicitudes.jsp";

    Connection con = null; PreparedStatement ps = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "UPDATE solicitud SET estado = 'RECHAZADA' "
          + "WHERE id_solicitud = ? AND id_cliente = ? AND estado = 'PENDIENTE'");
        ps.setInt(1, idSolicitud);
        ps.setInt(2, idUsuarioSesion);
        int filas = ps.executeUpdate();
        cerrar(ps);
        destino += filas > 0
            ? "?msg=" + java.net.URLEncoder.encode("Solicitud cancelada.", "UTF-8")
            : "?err=" + java.net.URLEncoder.encode("No se pudo cancelar esa solicitud.", "UTF-8");
    } catch (SQLException ex) {
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
