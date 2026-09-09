<%--
  cliente/cancelar_cita.jsp - Controlador (solo POST). El cliente solo
  puede cancelar citas propias que sigan en estado PENDIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idCita = aEntero(request.getParameter("id_cita"), 0);
    String destino = ctx + "/cliente/mis_citas.jsp";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        ps = con.prepareStatement(
            "SELECT id_cliente, estado FROM cita WHERE id_cita = ?");
        ps.setInt(1, idCita);
        rs = ps.executeQuery();
        boolean esDueño = rs.next() && rs.getInt("id_cliente") == idUsuarioSesion;
        boolean pendiente = esDueño && "PENDIENTE".equals(rs.getString("estado"));
        cerrar(rs, ps);

        if (!esDueño) {
            response.sendRedirect(ctx + "/acceso-denegado.jsp");
            return;
        }
        if (!pendiente) {
            response.sendRedirect(destino + "?err="
                + java.net.URLEncoder.encode("Esa cita ya no se puede cancelar.", "UTF-8"));
            return;
        }

        ps = con.prepareStatement("DELETE FROM cita WHERE id_cita = ?");
        ps.setInt(1, idCita);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(destino + "?msg="
            + java.net.URLEncoder.encode("Cita cancelada.", "UTF-8"));

    } catch (SQLException ex) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode("Error de base de datos: " + ex.getMessage(), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
