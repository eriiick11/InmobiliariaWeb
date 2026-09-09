<%--
  inmobiliaria/gestionar_cita.jsp - Controlador (solo POST) para que el
  agente apruebe, rechace o marque como completada una cita, siempre
  verificando que la propiedad de esa cita pertenezca a su inmobiliaria.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idCita = aEntero(request.getParameter("id_cita"), 0);
    String accion = request.getParameter("accion");
    String destino = ctx + "/inmobiliaria/citas.jsp";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        int idInmobiliaria = 0;
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        // La cita debe pertenecer a una propiedad de esta inmobiliaria
        ps = con.prepareStatement(
            "SELECT p.id_inmobiliaria, ci.estado FROM cita ci "
          + "INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
          + "WHERE ci.id_cita = ?");
        ps.setInt(1, idCita);
        rs = ps.executeQuery();
        boolean esDueño = rs.next() && rs.getInt("id_inmobiliaria") == idInmobiliaria;
        String estadoActual = esDueño ? rs.getString("estado") : null;
        cerrar(rs, ps);

        if (!esDueño) {
            response.sendRedirect(ctx + "/acceso-denegado.jsp");
            return;
        }

        String nuevoEstado = null;
        if ("aprobar".equals(accion) && "PENDIENTE".equals(estadoActual)) {
            nuevoEstado = "APROBADA";
        } else if ("rechazar".equals(accion) && "PENDIENTE".equals(estadoActual)) {
            nuevoEstado = "RECHAZADA";
        } else if ("completar".equals(accion) && "APROBADA".equals(estadoActual)) {
            nuevoEstado = "COMPLETADA";
        }

        if (nuevoEstado == null) {
            response.sendRedirect(destino + "?err="
                + java.net.URLEncoder.encode("Esa acción ya no es válida para el estado actual de la cita.", "UTF-8"));
            return;
        }

        ps = con.prepareStatement("UPDATE cita SET estado = ? WHERE id_cita = ?");
        ps.setString(1, nuevoEstado);
        ps.setInt(2, idCita);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(destino + "?msg="
            + java.net.URLEncoder.encode("Cita actualizada a " + nuevoEstado + ".", "UTF-8"));

    } catch (SQLException ex) {
        response.sendRedirect(destino + "?err="
            + java.net.URLEncoder.encode("Error de base de datos: " + ex.getMessage(), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
