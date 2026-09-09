<%--
  cliente/toggle_favorito.jsp - Controlador (solo POST) para agregar o
  quitar una propiedad de los favoritos del cliente en sesion.
  favorito es N:M (usuario<->propiedad) con llave primaria compuesta.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String accion = request.getParameter("accion"); // agregar | quitar
    String destino = ctx + "/propiedades/ficha.jsp?id=" + idPropiedad;

    Connection con = null; PreparedStatement ps = null;
    try {
        con = abrirConexion();

        if ("agregar".equals(accion)) {
            // INSERT IGNORE evita fallar si por doble clic ya quedo insertado antes
            ps = con.prepareStatement(
                "INSERT IGNORE INTO favorito (id_usuario, id_propiedad) VALUES (?, ?)");
            ps.setInt(1, idUsuarioSesion);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        } else if ("quitar".equals(accion)) {
            ps = con.prepareStatement(
                "DELETE FROM favorito WHERE id_usuario = ? AND id_propiedad = ?");
            ps.setInt(1, idUsuarioSesion);
            ps.setInt(2, idPropiedad);
            ps.executeUpdate();
        }
        cerrar(ps);

    } catch (SQLException ex) {
        destino += "&err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
