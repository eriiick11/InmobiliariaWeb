<%--
  inmobiliaria/propiedades.jsp - Lista las propiedades publicadas por la
  inmobiliaria (agente) que inicio sesion.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mis propiedades";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Mis propiedades</h3>
    <a href="<%= ctx %>/inmobiliaria/propiedad_form.jsp" class="btn btn-warning fw-bold">
        + Nueva propiedad</a>
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
            <th>Matricula</th><th>Titulo</th><th>Tipo</th><th>Ciudad</th>
            <th class="text-end">Precio</th><th>Estado</th><th></th>
        </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    int idInmobiliaria = 0;
    int filas = 0;
    try {
        con = abrirConexion();

        // 1) Averiguar el id_inmobiliaria del usuario en sesion
        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        if (idInmobiliaria == 0) {
%>
        <tr><td colspan="7" class="text-center text-muted py-4">
            Tu usuario no tiene un perfil de inmobiliaria asociado.</td></tr>
<%
        } else {
            ps = con.prepareStatement(
                "SELECT p.id_propiedad, p.matricula_inmobiliaria, p.titulo, p.precio, p.estado, "
              + "       t.nombre AS tipo, c.nombre AS ciudad "
              + "FROM propiedad p "
              + "  JOIN tipo_propiedad t ON t.id_tipo_propiedad = p.id_tipo_propiedad "
              + "  JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
              + "WHERE p.id_inmobiliaria = ? "
              + "ORDER BY p.fecha_publicacion DESC");
            ps.setInt(1, idInmobiliaria);
            rs = ps.executeQuery();
            while (rs.next()) {
                filas++;
                String estado = rs.getString("estado");
                String colorEstado = "DISPONIBLE".equals(estado) ? "success"
                                    : "INACTIVO".equals(estado) ? "secondary" : "info";
%>
        <tr>
            <td><code><%= esc(rs.getString("matricula_inmobiliaria")) %></code></td>
            <td><%= esc(rs.getString("titulo")) %></td>
            <td class="small text-muted"><%= esc(rs.getString("tipo")) %></td>
            <td class="small text-muted"><%= esc(rs.getString("ciudad")) %></td>
            <td class="text-end"><%= pesos(rs.getDouble("precio")) %></td>
            <td><span class="badge text-bg-<%= colorEstado %>"><%= estado %></span></td>
            <td class="text-end">
                <a class="btn btn-sm btn-outline-dark"
                   href="<%= ctx %>/inmobiliaria/propiedad_form.jsp?id=<%= rs.getInt("id_propiedad") %>">
                   Editar</a>
                <% if (!"INACTIVO".equals(estado)) { %>
                <form method="post" action="<%= ctx %>/inmobiliaria/acciones_propiedad.jsp"
                      class="d-inline"
                      onsubmit="return confirm('Dar de baja esta propiedad?')">
                    <input type="hidden" name="accion" value="baja">
                    <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
                    <button class="btn btn-sm btn-outline-danger">Dar de baja</button>
                </form>
                <% } else { %>
                <form method="post" action="<%= ctx %>/inmobiliaria/acciones_propiedad.jsp" class="d-inline">
                    <input type="hidden" name="accion" value="reactivar">
                    <input type="hidden" name="id_propiedad" value="<%= rs.getInt("id_propiedad") %>">
                    <button class="btn btn-sm btn-outline-success">Reactivar</button>
                </form>
                <% } %>
            </td>
        </tr>
<%
            }
        }
    } catch (SQLException ex) {
%>
        <tr><td colspan="7" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0 && idInmobiliaria != 0) {
%>
        <tr><td colspan="7" class="text-center text-muted py-4">
            Aun no has publicado propiedades.</td></tr>
<% } %>
    </tbody>
</table>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
