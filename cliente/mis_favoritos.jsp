<%--
  cliente/mis_favoritos.jsp - Lista las propiedades marcadas como favoritas
  por el cliente en sesion, con opcion de quitarlas.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mis favoritos";
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3">Mis favoritos</h3>

<% if (err != null) { %>
    <div class="alert alert-danger alert-dismissible fade show"><%= esc(err) %>
        <button class="btn-close" data-bs-dismiss="alert"></button></div>
<% } %>

<div class="row g-3">
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int filas = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.id_propiedad, p.titulo, p.precio, p.area, p.direccion, p.estado, "
          + "       tp.nombre AS tipo, c.nombre AS ciudad, f.fecha_agregado "
          + "FROM favorito f "
          + "INNER JOIN propiedad p ON p.id_propiedad = f.id_propiedad "
          + "INNER JOIN tipo_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "WHERE f.id_usuario = ? "
          + "ORDER BY f.fecha_agregado DESC");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            int idPropiedad = rs.getInt("id_propiedad");
            String estadoProp = rs.getString("estado");
%>
    <div class="col-md-6 col-lg-4">
      <div class="card shadow-sm h-100">
        <div class="card-body d-flex flex-column">
          <span class="badge text-bg-secondary mb-2" style="width:fit-content">
            <%= esc(rs.getString("tipo")) %></span>
          <h5 class="card-title"><%= esc(rs.getString("titulo")) %></h5>
          <p class="text-muted small mb-1">
            <%= esc(rs.getString("direccion")) %>, <%= esc(rs.getString("ciudad")) %></p>
          <p class="fw-bold mb-2"><%= pesos(rs.getDouble("precio")) %></p>
<%          if (!"DISPONIBLE".equals(estadoProp)) { %>
          <span class="badge text-bg-warning mb-2" style="width:fit-content">
            Ya no está disponible (<%= estadoProp %>)</span>
<%          } %>
          <div class="mt-auto d-flex gap-2">
            <a href="<%= ctx %>/propiedades/ficha.jsp?id=<%= idPropiedad %>"
               class="btn btn-sm btn-outline-dark">Ver ficha</a>
            <form method="post" action="<%= ctx %>/cliente/toggle_favorito.jsp" class="d-inline">
              <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
              <input type="hidden" name="accion" value="quitar">
              <button class="btn btn-sm btn-outline-danger">Quitar</button>
            </form>
          </div>
        </div>
      </div>
    </div>
<%
        }
    } catch (SQLException ex) {
%>
    <div class="col-12"><div class="alert alert-danger">Error: <%= esc(ex.getMessage()) %></div></div>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
    <div class="col-12">
      <p class="text-muted">Todavía no has guardado propiedades como favoritas.
         Explora el <a href="<%= ctx %>/propiedades/listado.jsp">catálogo</a> y usa
         el botón "Guardar en favoritos" en la ficha de cada propiedad.</p>
    </div>
<% } %>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
