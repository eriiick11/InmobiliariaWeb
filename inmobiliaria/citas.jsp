<%--
  inmobiliaria/citas.jsp - Lista las citas agendadas sobre las propiedades
  de la inmobiliaria (agente) en sesion, con acciones para aprobar,
  rechazar o marcar como completada.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Citas recibidas";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Citas recibidas</h3>
</div>

<% if (msg != null) { %>
    <div class="alert alert-success alert-dismissible fade show">
        <%= esc(msg) %>
        <button class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<% } %>
<% if (err != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        <%= esc(err) %>
        <button class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<% } %>

<div class="card shadow-sm">
<div class="table-responsive">
<table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
        <tr>
            <th>Propiedad</th><th>Cliente</th><th>Correo</th><th>Fecha y hora</th><th>Estado</th><th></th>
        </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int idInmobiliaria = 0;
    int filas = 0;
    try {
        con = abrirConexion();

        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        if (idInmobiliaria == 0) {
%>
        <tr><td colspan="6" class="text-center text-muted py-4">
            Tu usuario no tiene un perfil de inmobiliaria asociado.</td></tr>
<%
        } else {
            ps = con.prepareStatement(
                "SELECT ci.id_cita, ci.fecha_hora, ci.estado, "
              + "       p.titulo, u.correo, pf.nombres, pf.apellidos "
              + "FROM cita ci "
              + "INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
              + "INNER JOIN usuario u ON u.id_usuario = ci.id_cliente "
              + "INNER JOIN perfil pf ON pf.id_usuario = u.id_usuario "
              + "WHERE p.id_inmobiliaria = ? "
              + "ORDER BY FIELD(ci.estado,'PENDIENTE','APROBADA','COMPLETADA','RECHAZADA'), ci.fecha_hora");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            while (rs.next()) {
                filas++;
                String estado = rs.getString("estado");
                String colorEstado = "APROBADA".equals(estado) ? "success"
                                    : "RECHAZADA".equals(estado) ? "danger"
                                    : "COMPLETADA".equals(estado) ? "secondary" : "warning";
                int idCita = rs.getInt("id_cita");
%>
        <tr>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td><%= esc(rs.getString("nombres")) %> <%= esc(rs.getString("apellidos")) %></td>
            <td class="small text-muted"><%= esc(rs.getString("correo")) %></td>
            <td><%= rs.getTimestamp("fecha_hora") %></td>
            <td><span class="badge text-bg-<%= colorEstado %>"><%= estado %></span></td>
            <td class="text-end">
<%          if ("PENDIENTE".equals(estado)) { %>
                <form method="post" action="<%= ctx %>/inmobiliaria/gestionar_cita.jsp" class="d-inline">
                    <input type="hidden" name="id_cita" value="<%= idCita %>">
                    <input type="hidden" name="accion" value="aprobar">
                    <button class="btn btn-sm btn-outline-success">Aprobar</button>
                </form>
                <form method="post" action="<%= ctx %>/inmobiliaria/gestionar_cita.jsp" class="d-inline">
                    <input type="hidden" name="id_cita" value="<%= idCita %>">
                    <input type="hidden" name="accion" value="rechazar">
                    <button class="btn btn-sm btn-outline-danger">Rechazar</button>
                </form>
<%          } else if ("APROBADA".equals(estado)) { %>
                <form method="post" action="<%= ctx %>/inmobiliaria/gestionar_cita.jsp" class="d-inline">
                    <input type="hidden" name="id_cita" value="<%= idCita %>">
                    <input type="hidden" name="accion" value="completar">
                    <button class="btn btn-sm btn-outline-secondary">Marcar completada</button>
                </form>
<%          } %>
            </td>
        </tr>
<%
            }
        }
    } catch (SQLException ex) {
%>
        <tr><td colspan="6" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0 && idInmobiliaria != 0) {
%>
        <tr><td colspan="6" class="text-center text-muted py-4">
            Todavía no tienes citas agendadas sobre tus propiedades.</td></tr>
<% } %>
    </tbody>
</table>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
