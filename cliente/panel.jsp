<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mi panel";
    int totalCitasPend = 0, totalSolicitudesPend = 0, totalFavoritos = 0;
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM cita WHERE id_cliente = ? AND estado = 'PENDIENTE'");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) totalCitasPend = rs.getInt(1);
        rs.close(); ps.close();

        ps = con.prepareStatement(
            "SELECT COUNT(*) FROM solicitud WHERE id_cliente = ? AND estado = 'PENDIENTE'");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) totalSolicitudesPend = rs.getInt(1);
        rs.close(); ps.close();

        ps = con.prepareStatement("SELECT COUNT(*) FROM favorito WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) totalFavoritos = rs.getInt(1);
    } catch (SQLException ex) {
        // Si algo falla, los contadores quedan en 0 y la pagina sigue funcionando.
    } finally { cerrar(rs, ps, con); }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

  <div class="page-header">
    <div class="page-icon"><i class="bi bi-house-heart"></i></div>
    <div>
      <h1>Bienvenido, <%= esc(nombreSesion) %></h1>
      <p>Busca propiedades, agenda citas, radica solicitudes y guarda tus favoritas.</p>
    </div>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
      <div class="stat-card <%= totalCitasPend > 0 ? "stat-alert" : "" %>">
        <div class="stat-icon"><i class="bi bi-calendar-check"></i></div>
        <div>
          <div class="stat-value"><%= totalCitasPend %></div>
          <div class="stat-label">Citas pendientes</div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-4">
      <div class="stat-card <%= totalSolicitudesPend > 0 ? "stat-alert" : "" %>">
        <div class="stat-icon"><i class="bi bi-file-earmark-text"></i></div>
        <div>
          <div class="stat-value"><%= totalSolicitudesPend %></div>
          <div class="stat-label">Solicitudes pendientes</div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-4">
      <div class="stat-card">
        <div class="stat-icon"><i class="bi bi-heart"></i></div>
        <div>
          <div class="stat-value"><%= totalFavoritos %></div>
          <div class="stat-label">Propiedades favoritas</div>
        </div>
      </div>
    </div>
  </div>

  <div class="row g-3">
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-search"></i></div>
          <h5 class="card-title mb-0">Buscar propiedades</h5>
          <p class="card-text small text-muted mb-1">Filtra por ciudad, tipo, precio y características.</p>
          <a href="<%= ctx %>/propiedades/listado.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Buscar</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-calendar-check"></i></div>
          <h5 class="card-title mb-0">Mis citas</h5>
          <p class="card-text small text-muted mb-1">Revisa el estado de tus citas agendadas.</p>
          <a href="<%= ctx %>/cliente/mis_citas.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver citas</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-file-earmark-text"></i></div>
          <h5 class="card-title mb-0">Mis solicitudes</h5>
          <p class="card-text small text-muted mb-1">Sigue tus solicitudes de compra o arriendo y sube documentos.</p>
          <a href="<%= ctx %>/cliente/mis_solicitudes.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver solicitudes</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-heart"></i></div>
          <h5 class="card-title mb-0">Mis favoritos</h5>
          <p class="card-text small text-muted mb-1">Las propiedades que has guardado para revisar después.</p>
          <a href="<%= ctx %>/cliente/mis_favoritos.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver favoritos</a>
        </div>
      </div>
    </div>
  </div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
