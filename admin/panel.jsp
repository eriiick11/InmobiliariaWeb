<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Administración";
    int totalUsuarios = 0, totalPropiedades = 0, totalCitasPend = 0, totalSolicitudesPend = 0;
    Connection con = null; Statement st = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery("SELECT COUNT(*) FROM usuario"); if (rs.next()) totalUsuarios = rs.getInt(1); rs.close();
        rs = st.executeQuery("SELECT COUNT(*) FROM propiedad WHERE estado <> 'INACTIVO'"); if (rs.next()) totalPropiedades = rs.getInt(1); rs.close();
        rs = st.executeQuery("SELECT COUNT(*) FROM cita WHERE estado = 'PENDIENTE'"); if (rs.next()) totalCitasPend = rs.getInt(1); rs.close();
        rs = st.executeQuery("SELECT COUNT(*) FROM solicitud WHERE estado = 'PENDIENTE'"); if (rs.next()) totalSolicitudesPend = rs.getInt(1); rs.close();
    } catch (SQLException ex) {
        // Si alguna tabla difiere de nombre/estado, se ignora y quedan en 0.
    } finally { cerrar(st, con); }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

  <div class="page-header">
    <div class="page-icon"><i class="bi bi-shield-lock"></i></div>
    <div>
      <h1>Panel de administración</h1>
      <p>Acceso total: usuarios y roles, catálogos del sistema y auditoría.</p>
    </div>
  </div>

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="stat-card">
        <div class="stat-icon"><i class="bi bi-people"></i></div>
        <div>
          <div class="stat-value"><%= totalUsuarios %></div>
          <div class="stat-label">Usuarios registrados</div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card">
        <div class="stat-icon"><i class="bi bi-buildings"></i></div>
        <div>
          <div class="stat-value"><%= totalPropiedades %></div>
          <div class="stat-label">Propiedades activas</div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="stat-card <%= totalCitasPend > 0 ? "stat-alert" : "" %>">
        <div class="stat-icon"><i class="bi bi-calendar-check"></i></div>
        <div>
          <div class="stat-value"><%= totalCitasPend %></div>
          <div class="stat-label">Citas pendientes</div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
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
    <div class="col-md-4">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-person-gear"></i></div>
          <h5 class="card-title mb-0">Usuarios y roles</h5>
          <p class="card-text small text-muted mb-1">Asigna o revoca roles, activa o inactiva cuentas.</p>
          <a href="<%= ctx %>/admin/usuarios.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Gestionar usuarios</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-tags"></i></div>
          <h5 class="card-title mb-0">Catálogos del sistema</h5>
          <p class="card-text small text-muted mb-1">Ciudades, tipos de propiedad y características.</p>
          <a href="<%= ctx %>/admin/catalogos.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Gestionar catálogos</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card quick-card shadow-sm h-100">
        <div class="card-body">
          <div class="quick-icon"><i class="bi bi-clock-history"></i></div>
          <h5 class="card-title mb-0">Auditoría</h5>
          <p class="card-text small text-muted mb-1">Historial de accesos y cambios en el sistema.</p>
          <a href="<%= ctx %>/admin/auditoria.jsp" class="btn btn-warning fw-bold btn-sm align-self-start">Ver auditoría</a>
        </div>
      </div>
    </div>
  </div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
