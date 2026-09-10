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

  <h1 class="mb-1">Panel de administración</h1>
  <p class="text-muted mb-4">Acceso total: usuarios y roles, catálogos del sistema y auditoría.</p>

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center py-3">
        <div class="fs-3 fw-bold"><%= totalUsuarios %></div>
        <div class="small text-muted">Usuarios registrados</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center py-3">
        <div class="fs-3 fw-bold"><%= totalPropiedades %></div>
        <div class="small text-muted">Propiedades activas</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center py-3">
        <div class="fs-3 fw-bold"><%= totalCitasPend %></div>
        <div class="small text-muted">Citas pendientes</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm text-center py-3">
        <div class="fs-3 fw-bold"><%= totalSolicitudesPend %></div>
        <div class="small text-muted">Solicitudes pendientes</div>
      </div>
    </div>
  </div>

  <div class="row g-3">
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Usuarios y roles</h5>
          <p class="card-text small text-muted">Asigna o revoca roles, activa o inactiva cuentas.</p>
          <a href="<%= ctx %>/admin/usuarios.jsp" class="btn btn-warning fw-bold btn-sm">Gestionar usuarios</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Catálogos del sistema</h5>
          <p class="card-text small text-muted">Ciudades, tipos de propiedad y características.</p>
          <a href="<%= ctx %>/admin/catalogos.jsp" class="btn btn-warning fw-bold btn-sm">Gestionar catálogos</a>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <h5 class="card-title">Auditoría</h5>
          <p class="card-text small text-muted">Historial de accesos y cambios en el sistema.</p>
          <a href="<%= ctx %>/admin/auditoria.jsp" class="btn btn-warning fw-bold btn-sm">Ver auditoría</a>
        </div>
      </div>
    </div>
  </div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
