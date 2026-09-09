<%--
  cliente/agendar_cita.jsp - Controlador (solo POST) para que un CLIENTE
  agende una visita a una propiedad. Respeta la restriccion UNIQUE
  (id_propiedad, fecha_hora) de la tabla cita: si ya hay una visita
  agendada en ese horario para esa propiedad, se captura el error y se
  muestra un mensaje claro en vez de una excepcion de Java.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    request.setCharacterEncoding("UTF-8");
    int idPropiedad = aEntero(request.getParameter("id_propiedad"), 0);
    String fechaHoraTexto = request.getParameter("fecha_hora"); // formato datetime-local: yyyy-MM-ddTHH:mm
    String destinoFicha = ctx + "/propiedades/ficha.jsp?id=" + idPropiedad;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        // ---------- Validaciones basicas ----------
        if (idPropiedad <= 0 || fechaHoraTexto == null || fechaHoraTexto.trim().isEmpty()) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("Debes indicar una fecha y hora validas.", "UTF-8"));
            return;
        }

        Timestamp fechaHora;
        try {
            // datetime-local llega como "2026-09-20T10:30" -> se completa con segundos
            fechaHora = Timestamp.valueOf(fechaHoraTexto.replace("T", " ") + ":00");
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("La fecha y hora no tienen un formato valido.", "UTF-8"));
            return;
        }

        if (fechaHora.before(new Timestamp(System.currentTimeMillis()))) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("La fecha de la visita debe ser futura.", "UTF-8"));
            return;
        }

        con = abrirConexion();

        // La propiedad debe existir y estar disponible para agendar visita
        ps = con.prepareStatement("SELECT estado FROM propiedad WHERE id_propiedad = ?");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        boolean disponible = rs.next() && "DISPONIBLE".equals(rs.getString("estado"));
        cerrar(rs, ps);

        if (!disponible) {
            response.sendRedirect(destinoFicha + "&err="
                + java.net.URLEncoder.encode("Esta propiedad ya no admite visitas.", "UTF-8"));
            return;
        }

        ps = con.prepareStatement(
            "INSERT INTO cita (id_propiedad, id_cliente, fecha_hora, estado) "
          + "VALUES (?, ?, ?, 'PENDIENTE')");
        ps.setInt(1, idPropiedad);
        ps.setInt(2, idUsuarioSesion);
        ps.setTimestamp(3, fechaHora);
        ps.executeUpdate();
        cerrar(ps);

        response.sendRedirect(ctx + "/cliente/mis_citas.jsp?msg="
            + java.net.URLEncoder.encode("Cita solicitada. Queda pendiente de aprobación.", "UTF-8"));

    } catch (SQLIntegrityConstraintViolationException ex) {
        // Cubre la UNIQUE (id_propiedad, fecha_hora): dos visitas a la misma hora
        response.sendRedirect(destinoFicha + "&err="
            + java.net.URLEncoder.encode(mensajeError(ex), "UTF-8"));
    } catch (SQLException ex) {
        response.sendRedirect(destinoFicha + "&err="
            + java.net.URLEncoder.encode("Error de base de datos: " + ex.getMessage(), "UTF-8"));
    } finally {
        cerrar(rs, ps, con);
    }
%>
