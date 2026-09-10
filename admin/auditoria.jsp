<%--
  admin/auditoria.jsp - Consulta de la bitacora de actividad del sistema
  (solo lectura). Columnas reales de la tabla auditoria: id_auditoria,
  id_usuario, accion, tabla_afectada, fecha_hora, detalle.
  Permite filtrar por tipo de accion y por tabla afectada.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Auditoría";
    String fAccion = request.getParameter("accion");
    String fTabla  = request.getParameter("tabla");
    if (fAccion != null && fAccion.trim().isEmpty()) fAccion = null;
    if (fTabla  != null && fTabla.trim().isEmpty())  fTabla  = null;
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Auditoría del sistema</h3>
    <a href="<%= ctx %>/admin/panel.jsp" class="btn btn-outline-dark btn-sm">&larr; Volver</a>
</div>

<form method="get" class="row g-2 mb-3">
    <div class="col-auto">
        <select name="accion" class="form-select form-select-sm">
            <option value="">Todas las acciones</option>
            <% for (String a : new String[]{"LOGIN","INSERT","UPDATE","DELETE"}) { %>
                <option value="<%= a %>" <%= a.equals(fAccion) ? "selected" : "" %>><%= a %></option>
            <% } %>
        </select>
    </div>
    <div class="col-auto">
        <input type="text" name="tabla" class="form-control form-control-sm"
               placeholder="Tabla afectada (ej: propiedad)"
               value="<%= fTabla != null ? esc(fTabla) : "" %>">
    </div>
    <div class="col-auto">
        <button class="btn btn-sm btn-outline-dark">Filtrar</button>
        <a href="<%= ctx %>/admin/auditoria.jsp" class="btn btn-sm btn-outline-secondary">Limpiar</a>
    </div>
</form>

<div class="card shadow-sm">
<div class="table-responsive">
<table class="table table-hover align-middle mb-0 small">
    <thead class="table-dark">
        <tr>
            <th>Fecha y hora</th><th>Usuario</th><th>Acción</th>
            <th>Tabla afectada</th><th>Detalle</th>
        </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        StringBuilder sql = new StringBuilder(
            "SELECT a.fecha_hora, a.accion, a.tabla_afectada, a.detalle, u.username "
          + "FROM auditoria a LEFT JOIN usuario u ON u.id_usuario = a.id_usuario WHERE 1=1 ");
        if (fAccion != null) sql.append("AND a.accion = ? ");
        if (fTabla  != null) sql.append("AND a.tabla_afectada LIKE ? ");
        sql.append("ORDER BY a.fecha_hora DESC");

        ps = con.prepareStatement(sql.toString());
        int idx = 1;
        if (fAccion != null) ps.setString(idx++, fAccion);
        if (fTabla  != null) ps.setString(idx++, "%" + fTabla + "%");

        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            String accion = rs.getString("accion");
            String colorAccion = "LOGIN".equals(accion) ? "info"
                                : "INSERT".equals(accion) ? "success"
                                : "DELETE".equals(accion) ? "danger" : "warning";
%>
        <tr>
            <td class="text-nowrap"><%= rs.getTimestamp("fecha_hora") %></td>
            <td><code><%= rs.getString("username") != null ? esc(rs.getString("username")) : "—" %></code></td>
            <td><span class="badge text-bg-<%= colorAccion %>"><%= esc(accion) %></span></td>
            <td class="text-muted"><%= esc(rs.getString("tabla_afectada")) %></td>
            <td><%= esc(rs.getString("detalle")) %></td>
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
        <tr><td colspan="5" class="text-center text-muted py-4">No hay registros de auditoría.</td></tr>
<% } %>
    </tbody>
</table>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
