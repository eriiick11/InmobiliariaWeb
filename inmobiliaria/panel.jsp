<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mi panel";
    int idInmobiliaria = 0;
    int totalActivas = 0, totalCitasPend = 0, totalSolicitudesPend = 0;
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        // 1) Averiguar el id_inmobiliaria del usuario en sesion (mismo patron que propiedades.jsp)
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        rs.close(); ps.close();

        if (idInmobiliaria != 0) {
            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM propiedad WHERE id_inmobiliaria = ? AND estado <> 'INACTIVO'");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            if (rs.next()) totalActivas = rs.getInt(1);
            rs.close(); ps.close();

            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM cita ci INNER JOIN propiedad p ON ci.id_propiedad = p.id_propiedad "
              + "WHERE p.id_inmobiliaria = ? AND ci.estado = 'PENDIENTE'");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            if (rs.next()) totalCitasPend = rs.getInt(1);
            rs.close(); ps.close();

            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM solicitud s INNER JOIN propiedad p ON s.id_propiedad = p.id_propiedad "
              + "WHERE p.id_inmobiliaria = ? AND s.estado = 'PENDIENTE'");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            if (rs.next()) totalSolicitudesPend = rs.getInt(1);
        }
    } catch (SQLException ex) {
        // Si algo falla, los contadores quedan en 0 y la pagina sigue funcionando.
    } finally { cerrar(rs, ps, con); }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

  <div class="page-header">
    <div class="page-icon"><i class="bi bi-buildings"></i></div>
    <div>
      <h1>Panel de la inmobiliaria</h1>
      <p>Publica y edita tus propiedades, atiende citas y responde solicitudes de compra o arriendo.</p>
    </div>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-4">
      <div class="stat-card">
        <div class="stat-icon"><i class="bi bi-house-check"></i></div>
        <div>
          <div class="stat-value"><%= totalActivas %></div>
          <div class="stat-label">Propiedades activas</div>
        </div>
      </div>
    </div>
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
  </div>

  <div class="row g-3">
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-plus-lg"></i></div>
          <h5 class="card-title mb-0">Publicar propiedad</h5>
          <p class="card-text small text-muted mb-1">Crea una nueva ficha con imágenes y características.</p>
          <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Nueva propiedad</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-buildings"></i></div>
          <h5 class="card-title mb-0">Mis propiedades</h5>
          <p class="card-text small text-muted mb-1">Edita, da de baja o reactiva tus fichas publicadas.</p>
          <a href="<%= ctx %>/inmobiliaria/propiedades.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver propiedades</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-calendar-week"></i></div>
          <h5 class="card-title mb-0">Citas recibidas</h5>
          <p class="card-text small text-muted mb-1">Aprueba, rechaza o marca como completadas.</p>
          <a href="<%= ctx %>/inmobiliaria/citas.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver citas</a>
        </div>
      </div>
    </div>
    <div class="col-md-3">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-inboxes"></i></div>
          <h5 class="card-title mb-0">Solicitudes recibidas</h5>
          <p class="card-text small text-muted mb-1">Revisa documentos y aprueba o rechaza solicitudes.</p>
          <a href="<%= ctx %>/inmobiliaria/solicitudes.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver solicitudes</a>
        </div>
      </div>
    </div>
  </div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
