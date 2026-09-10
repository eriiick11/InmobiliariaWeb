<%--
  admin/acciones_catalogo.jsp - Alta y baja de los catalogos parametrizables:
  ciudad, tipo_propiedad, caracteristica. La baja se bloquea con un mensaje
  claro si el valor esta en uso (violacion de llave foranea), en vez de
  dejar pasar la excepcion de Java cruda.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    int id = aEntero(request.getParameter("id"), 0);
    String destino = ctx + "/admin/catalogos.jsp";

    Connection con = null; PreparedStatement ps = null;
    try {
        con = abrirConexion();

        if ("agregar_ciudad".equals(accion)) {
            ps = con.prepareStatement("INSERT INTO ciudad (nombre, departamento) VALUES (?, ?)");
            ps.setString(1, request.getParameter("nombre"));
            ps.setString(2, request.getParameter("departamento"));
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Ciudad agregada.", "UTF-8");

        } else if ("eliminar_ciudad".equals(accion)) {
            ps = con.prepareStatement("DELETE FROM ciudad WHERE id_ciudad = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Ciudad eliminada.", "UTF-8");

        } else if ("agregar_tipo".equals(accion)) {
            ps = con.prepareStatement("INSERT INTO tipo_propiedad (nombre) VALUES (?)");
            ps.setString(1, request.getParameter("nombre"));
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Tipo de propiedad agregado.", "UTF-8");

        } else if ("eliminar_tipo".equals(accion)) {
            ps = con.prepareStatement("DELETE FROM tipo_propiedad WHERE id_tipo_propiedad = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Tipo de propiedad eliminado.", "UTF-8");

        } else if ("agregar_caracteristica".equals(accion)) {
            ps = con.prepareStatement("INSERT INTO caracteristica (nombre) VALUES (?)");
            ps.setString(1, request.getParameter("nombre"));
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Característica agregada.", "UTF-8");

        } else if ("eliminar_caracteristica".equals(accion)) {
            ps = con.prepareStatement("DELETE FROM caracteristica WHERE id_caracteristica = ?");
            ps.setInt(1, id);
            ps.executeUpdate();
            destino += "?msg=" + java.net.URLEncoder.encode("Característica eliminada.", "UTF-8");
        }
        cerrar(ps);

    } catch (SQLIntegrityConstraintViolationException ex) {
        // La baja choca con una FK: el valor esta siendo usado por al menos una propiedad.
        destino += "?err=" + java.net.URLEncoder.encode(
            "No se puede eliminar: hay propiedades que usan este valor.", "UTF-8");
    } catch (SQLException ex) {
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
