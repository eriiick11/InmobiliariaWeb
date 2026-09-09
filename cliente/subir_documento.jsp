<%--
  cliente/subir_documento.jsp - Controlador (solo POST) para radicar un
  documento sobre una solicitud propia que siga PENDIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idSolicitud = aEntero(request.getParameter("id_solicitud"), 0);
    String nombreArchivo = request.getParameter("nombre_archivo");
    String urlArchivo = request.getParameter("url_archivo");
    String destino = ctx + "/cliente/mis_solicitudes.jsp";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        // La solicitud debe ser del cliente en sesion y seguir PENDIENTE
        ps = con.prepareStatement(
            "SELECT estado FROM solicitud WHERE id_solicitud = ? AND id_cliente = ?");
        ps.setInt(1, idSolicitud);
        ps.setInt(2, idUsuarioSesion);
        rs = ps.executeQuery();
        boolean puedeSubir = rs.next() && "PENDIENTE".equals(rs.getString("estado"));
        cerrar(rs, ps);

        if (!puedeSubir) {
            response.sendRedirect(destino + "?err="
                + java.net.URLEncoder.encode("Esa solicitud no admite mas documentos.", "UTF-8"));
            return;
        }

        ps = con.prepareStatement(
            "INSERT INTO documento_solicitud (id_solicitud, nombre_archivo, url_archivo) VALUES (?, ?, ?)");
        ps.setInt(1, idSolicitud);
        ps.setString(2, nombreArchivo == null ? "documento" : nombreArchivo.trim());
        ps.setString(3, urlArchivo);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(destino + "?msg="
            + java.net.URLEncoder.encode("Documento radicado.", "UTF-8"));

    } catch (SQLException ex) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
