<%--
  admin/acciones_usuario.jsp - Controlador de acciones sobre un usuario:
  asignar_rol / revocar_rol (tabla N:M usuario_rol) y activar / inactivar
  la cuenta (columna usuario.activo). Solo el rol ADMINISTRADOR llega aqui.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    int idUsuario = aEntero(request.getParameter("id_usuario"), 0);
    String destino = ctx + "/admin/usuarios.jsp";

    // Un administrador no puede inactivarse ni quitarse el rol a si mismo:
    // evita que se quede sin acceso al panel por accidente.
    if (idUsuario == idUsuarioSesion && ("inactivar".equals(accion) || "revocar_rol".equals(accion))) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode("No puedes modificar tu propio acceso desde aqui.", "UTF-8"));
        return;
    }

    Connection con = null; PreparedStatement ps = null;
    try {
        con = abrirConexion();
        con.setAutoCommit(false);

        if ("asignar_rol".equals(accion)) {
            int idRol = aEntero(request.getParameter("id_rol"), 0);
            ps = con.prepareStatement(
                "INSERT INTO usuario_rol (id_usuario, id_rol, fecha_asignacion) VALUES (?, ?, NOW())");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino += "?msg=" + java.net.URLEncoder.encode("Rol asignado.", "UTF-8");

        } else if ("revocar_rol".equals(accion)) {
            int idRol = aEntero(request.getParameter("id_rol"), 0);
            ps = con.prepareStatement(
                "DELETE FROM usuario_rol WHERE id_usuario = ? AND id_rol = ?");
            ps.setInt(1, idUsuario);
            ps.setInt(2, idRol);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino += "?msg=" + java.net.URLEncoder.encode("Rol revocado.", "UTF-8");

        } else if ("activar".equals(accion)) {
            ps = con.prepareStatement("UPDATE usuario SET activo = TRUE WHERE id_usuario = ?");
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino += "?msg=" + java.net.URLEncoder.encode("Cuenta activada.", "UTF-8");

        } else if ("inactivar".equals(accion)) {
            ps = con.prepareStatement("UPDATE usuario SET activo = FALSE WHERE id_usuario = ?");
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
            cerrar(ps);
            con.commit();
            destino += "?msg=" + java.net.URLEncoder.encode("Cuenta inactivada.", "UTF-8");
        }

    } catch (SQLIntegrityConstraintViolationException ex) {
        deshacer(con);
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } catch (SQLException ex) {
        deshacer(con);
        destino += "?err=" + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8");
    } finally {
        cerrar(ps, con);
    }
    response.sendRedirect(destino);
%>
