<%--
  inmobiliaria/solicitudes.jsp - Lista las solicitudes recibidas sobre las
  propiedades de la inmobiliaria en sesion, con sus documentos y acciones
  de aprobar/rechazar.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Solicitudes recibidas";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3">Solicitudes recibidas</h3>

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
    <p class="text-muted">Tu usuario no tiene un perfil de inmobiliaria asociado.</p>
<%
        } else {
            ps = con.prepareStatement(
                "SELECT s.id_solicitud, s.tipo, s.estado, s.fecha_solicitud, "
              + "       p.titulo, u.correo, pf.nombres, pf.apellidos, "
              + "       (SELECT COUNT(*) FROM documento_solicitud d WHERE d.id_solicitud = s.id_solicitud) AS n_docs "
              + "FROM solicitud s "
              + "INNER JOIN propiedad p ON p.id_propiedad = s.id_propiedad "
              + "INNER JOIN usuario u ON u.id_usuario = s.id_cliente "
              + "INNER JOIN perfil pf ON pf.id_usuario = u.id_usuario "
              + "WHERE p.id_inmobiliaria = ? "
              + "ORDER BY FIELD(s.estado,'PENDIENTE','APROBADA','RECHAZADA'), s.fecha_solicitud DESC");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            while (rs.next()) {
                filas++;
                int idSolicitud = rs.getInt("id_solicitud");
                String estado = rs.getString("estado");
                String colorEstado = "APROBADA".equals(estado) ? "success"
                                    : "RECHAZADA".equals(estado) ? "danger" : "warning";
%>
<div class="card shadow-sm mb-3">
  <div class="card-body">
    <div class="d-flex justify-content-between align-items-start">
      <div>
        <h5 class="mb-1"><%= esc(rs.getString("titulo")) %> — <%= rs.getString("tipo") %></h5>
        <p class="text-muted small mb-1">
          <%= esc(rs.getString("nombres")) %> <%= esc(rs.getString("apellidos")) %>
          (<%= esc(rs.getString("correo")) %>) · <%= rs.getTimestamp("fecha_solicitud") %>
          · <%= rs.getInt("n_docs") %> documento(s)
        </p>
      </div>
      <span class="badge text-bg-<%= colorEstado %>"><%= estado %></span>
    </div>
<%          if ("PENDIENTE".equals(estado)) { %>
    <form method="post" action="<%= ctx %>/inmobiliaria/gestionar_solicitud.jsp" class="d-inline mt-2">
      <input type="hidden" name="id_solicitud" value="<%= idSolicitud %>">
      <input type="hidden" name="accion" value="aprobar">
      <button class="btn btn-sm btn-outline-success">Aprobar</button>
    </form>
    <form method="post" action="<%= ctx %>/inmobiliaria/gestionar_solicitud.jsp" class="d-inline mt-2">
      <input type="hidden" name="id_solicitud" value="<%= idSolicitud %>">
      <input type="hidden" name="accion" value="rechazar">
      <button class="btn btn-sm btn-outline-danger">Rechazar</button>
    </form>
<%          } %>
  </div>
</div>
<%
            }
        }
    } catch (SQLException ex) {
%>
    <div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0 && idInmobiliaria != 0) {
%>
    <p class="text-muted">Todavía no tienes solicitudes sobre tus propiedades.</p>
<% } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
