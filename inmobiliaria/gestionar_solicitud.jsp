<%--
  inmobiliaria/gestionar_solicitud.jsp - Aprueba o rechaza una solicitud,
  verificando que la propiedad pertenezca a la inmobiliaria en sesion.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
    String accion = request.getParameter("accion");
    String destino = ctx + "/inmobiliaria/solicitudes.jsp";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        int idInmobiliaria = 0;
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        String nuevoEstado = "aprobar".equals(accion) ? "APROBADA"
                            : "rechazar".equals(accion) ? "RECHAZADA" : null;
        if (nuevoEstado == null) {
            response.sendRedirect(destino);
            return;
        }

        ps = con.prepareStatement(
            "UPDATE solicitud s "
          + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
          + "SET s.estado = ? "
          + "WHERE s.id_solicitud = ? AND p.id_inmobiliaria = ? AND s.estado = 'PENDIENTE'");
        ps.setString(1, nuevoEstado);
        ps.setInt(2, idSolicitud);
        ps.setInt(3, idInmobiliaria);
        int filas = ps.executeUpdate();
        cerrar(ps);

        destino += filas > 0
            ? "?msg=" + java.net.URLEncoder.encode("Solicitud actualizada.", "UTF-8")
            : "?err=" + java.net.URLEncoder.encode("No se pudo actualizar esa solicitud.", "UTF-8");

    } catch (SQLException ex) {
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(rs, ps, con);
    }
    response.sendRedirect(destino);
%>
