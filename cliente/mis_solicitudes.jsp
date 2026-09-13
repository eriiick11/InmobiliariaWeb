<%--
  cliente/mis_solicitudes.jsp - Lista las solicitudes del cliente en sesion,
  con sus documentos radicados y un formulario para subir uno nuevo mientras
  la solicitud siga PENDIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mis solicitudes";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3">Mis solicitudes</h3>

<% if (msg != null) { %>
    <div class="alert alert-success alert-dismissible fade show"><%= esc(msg) %>
        <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>
<% if (err != null) { %>
    <div class="alert alert-danger alert-dismissible fade show"><%= esc(err) %>
        <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>

<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT s.id_solicitud, s.tipo, s.estado, s.fecha_solicitud, "
          + "       p.id_propiedad, p.titulo "
          + "FROM solicitud s "
          + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
          + "WHERE s.id_cliente = ? "
          + "ORDER BY FIELD(s.estado,'PENDIENTE','APROBADA','RECHAZADA'), s.fecha_solicitud DESC");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            int idSolicitud = rs.getInt("id_solicitud");
            String estado = rs.getString("estado");
            String colorEstado = "APROBADA".equals(estado) ? "success"
                                : "RECHAZADA".equals(estado) ? "danger" : "warning";
%>
<div class="card shadow-sm mb-3">
  <div class="card-header d-flex justify-content-between align-items-center">
    <div>
      <h5 class="mb-0"><%= esc(rs.getString("titulo")) %></h5>
      <p class="text-muted small mb-0">
        <%= rs.getString("tipo") %> · Radicada el <%= rs.getTimestamp("fecha_solicitud") %>
      </p>
    </div>
    <span class="badge text-bg-<%= colorEstado %>"><%= estado %></span>
  </div>
  <div class="card-body">
    <h6 class="mb-1">Documentos radicados</h6>
    <ul class="list-group list-group-flush mb-2">
<%
        PreparedStatement psDoc = con.prepareStatement(
            "SELECT nombre_archivo, url_archivo, fecha_carga FROM documento_solicitud "
          + "WHERE id_solicitud = ? ORDER BY fecha_carga");
        psDoc.setInt(1, idSolicitud);
        ResultSet rsDoc = psDoc.executeQuery();
        boolean hayDocs = false;
        while (rsDoc.next()) {
            hayDocs = true;
%>
      <li class="list-group-item px-0 py-1">
        <a href="<%= esc(rsDoc.getString("url_archivo")) %>" target="_blank" rel="noopener">
          <%= esc(rsDoc.getString("nombre_archivo")) %></a>
        <span class="text-muted small"> — <%= rsDoc.getTimestamp("fecha_carga") %></span>
      </li>
<%      }
        cerrar(rsDoc, psDoc);
        if (!hayDocs) { %>
      <li class="list-group-item px-0 py-1 text-muted small">Sin documentos todavía.</li>
<%      } %>
    </ul>

<%      if ("PENDIENTE".equals(estado)) { %>
    <form method="post" action="<%= ctx %>/cliente/subir_documento.jsp"
          enctype="multipart/form-data" class="row g-2 align-items-end">
      <input type="hidden" name="id_solicitud" value="<%= idSolicitud %>">
      <div class="col-md-10">
        <label class="form-label small">Archivo (PDF, JPG o PNG)</label>
        <input type="file" name="archivo_documento" class="form-control form-control-sm" required
               accept=".pdf,.jpg,.jpeg,.png">
      </div>
      <div class="col-md-2 d-grid">
        <button class="btn btn-sm btn-outline-dark">Subir</button>
      </div>
    </form>
    <form method="post" action="<%= ctx %>/cliente/cancelar_solicitud.jsp" class="mt-2"
          onsubmit="return confirm('Cancelar esta solicitud?')">
      <input type="hidden" name="id_solicitud" value="<%= idSolicitud %>">
      <button class="btn btn-sm btn-outline-danger">Cancelar solicitud</button>
    </form>
<%      } %>
  </div>
</div>
<%
        }
    } catch (SQLException ex) {
%>
        <div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
    <p class="text-muted">Todavía no has radicado ninguna solicitud. Búscalas desde
       <a href="<%= ctx %>/propiedades/listado.jsp">el catálogo</a>.</p>
<% } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
