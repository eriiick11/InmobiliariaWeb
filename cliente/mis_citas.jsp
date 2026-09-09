<%--
  cliente/mis_citas.jsp - Lista las citas agendadas por el CLIENTE en
  sesion, con la propiedad y el estado (PENDIENTE/APROBADA/RECHAZADA/COMPLETADA).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mis citas";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Mis citas</h3>
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
            <th>Propiedad</th><th>Ciudad</th><th>Fecha y hora</th><th>Estado</th><th></th>
        </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT ci.id_cita, ci.fecha_hora, ci.estado, "
          + "       p.id_propiedad, p.titulo, c.nombre AS ciudad "
          + "FROM cita ci "
          + "INNER JOIN propiedad p ON p.id_propiedad = ci.id_propiedad "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "WHERE ci.id_cliente = ? "
          + "ORDER BY ci.fecha_hora DESC");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            String estado = rs.getString("estado");
            String colorEstado = "APROBADA".equals(estado) ? "success"
                                : "RECHAZADA".equals(estado) ? "danger"
                                : "COMPLETADA".equals(estado) ? "secondary" : "warning";
%>
        <tr>
            <td>
                <a href="<%= ctx %>/propiedades/ficha.jsp?id=<%= rs.getInt("id_propiedad") %>">
                    <%= esc(rs.getString("titulo")) %></a>
            </td>
            <td class="small text-muted"><%= esc(rs.getString("ciudad")) %></td>
            <td><%= rs.getTimestamp("fecha_hora") %></td>
            <td><span class="badge text-bg-<%= colorEstado %>"><%= estado %></span></td>
            <td class="text-end">
<%          if ("PENDIENTE".equals(estado)) { %>
                <form method="post" action="<%= ctx %>/cliente/cancelar_cita.jsp" class="d-inline"
                      onsubmit="return confirm('¿Cancelar esta cita?')">
                    <input type="hidden" name="id_cita" value="<%= rs.getInt("id_cita") %>">
                    <button class="btn btn-sm btn-outline-danger">Cancelar</button>
                </form>
<%          } %>
            </td>
        </tr>
<%
        }
    } catch (SQLException ex) {
%>
        <tr><td colspan="5" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
        <tr><td colspan="5" class="text-center text-muted py-4">
            Todavía no has agendado ninguna cita. Busca una propiedad y solicita una visita.</td></tr>
<% } %>
    </tbody>
</table>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
