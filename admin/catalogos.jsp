<%--
  admin/catalogos.jsp - Parametrizacion de los catalogos del sistema:
  ciudad, tipo_propiedad y caracteristica. Cada uno se administra con
  un formulario de alta y un boton de baja, via acciones_catalogo.jsp.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Catálogos";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Catálogos del sistema</h3>
    <a href="<%= ctx %>/admin/panel.jsp" class="btn btn-outline-dark btn-sm">&larr; Volver</a>
</div>

<% if (msg != null) { %>
    <div class="alert alert-success alert-dismissible fade show">
        <%= esc(msg) %><button class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<% } %>
<% if (err != null) { %>
    <div class="alert alert-danger alert-dismissible fade show">
        <%= esc(err) %><button class="btn-close" data-bs-dismiss="alert"></button>
    </div>
<% } %>

<%!
    /** Imprime una mini-tabla de catalogo (id, nombre) con alta y baja.
     *  Recibe la tabla, la columna id y el nombre de la accion de alta. */
%>
<%
    Connection con = null; Statement st = null; ResultSet rs = null;
    try { con = abrirConexion(); } catch (SQLException ex) { %>
        <div class="alert alert-danger">No se pudo conectar: <%= esc(ex.getMessage()) %></div>
<%  }
%>

<div class="row g-3">
  <!-- ===================== CIUDAD ===================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header fw-bold">Ciudades</div>
      <ul class="list-group list-group-flush">
<%
    if (con != null) {
        try {
            st = con.createStatement();
            rs = st.executeQuery("SELECT id_ciudad, nombre, departamento FROM ciudad ORDER BY nombre");
            while (rs.next()) {
%>
        <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><%= esc(rs.getString("nombre")) %>
                <small class="text-muted">(<%= esc(rs.getString("departamento")) %>)</small></span>
            <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-inline"
                  onsubmit="return confirm('¿Eliminar esta ciudad?')">
                <input type="hidden" name="accion" value="eliminar_ciudad">
                <input type="hidden" name="id" value="<%= rs.getInt("id_ciudad") %>">
                <button class="btn btn-sm btn-outline-danger">&times;</button>
            </form>
        </li>
<%
            }
            cerrar(rs, st);
        } catch (SQLException ex) { %>
        <li class="list-group-item text-danger small">Error: <%= esc(ex.getMessage()) %></li>
<%      }
    }
%>
      </ul>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-flex gap-2">
            <input type="hidden" name="accion" value="agregar_ciudad">
            <input type="text" name="nombre" class="form-control form-control-sm" placeholder="Nombre" required>
            <input type="text" name="departamento" class="form-control form-control-sm" placeholder="Depto" required>
            <button class="btn btn-sm btn-warning fw-bold text-nowrap">+</button>
        </form>
      </div>
    </div>
  </div>

  <!-- ===================== TIPO DE PROPIEDAD ===================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header fw-bold">Tipos de propiedad</div>
      <ul class="list-group list-group-flush">
<%
    if (con != null) {
        try {
            st = con.createStatement();
            rs = st.executeQuery("SELECT id_tipo_propiedad, nombre FROM tipo_propiedad ORDER BY nombre");
            while (rs.next()) {
%>
        <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><%= esc(rs.getString("nombre")) %></span>
            <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-inline"
                  onsubmit="return confirm('¿Eliminar este tipo de propiedad?')">
                <input type="hidden" name="accion" value="eliminar_tipo">
                <input type="hidden" name="id" value="<%= rs.getInt("id_tipo_propiedad") %>">
                <button class="btn btn-sm btn-outline-danger">&times;</button>
            </form>
        </li>
<%
            }
            cerrar(rs, st);
        } catch (SQLException ex) { %>
        <li class="list-group-item text-danger small">Error: <%= esc(ex.getMessage()) %></li>
<%      }
    }
%>
      </ul>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-flex gap-2">
            <input type="hidden" name="accion" value="agregar_tipo">
            <input type="text" name="nombre" class="form-control form-control-sm" placeholder="Nombre" required>
            <button class="btn btn-sm btn-warning fw-bold text-nowrap">+</button>
        </form>
      </div>
    </div>
  </div>

  <!-- ===================== CARACTERISTICA ===================== -->
  <div class="col-md-4">
    <div class="card shadow-sm h-100">
      <div class="card-header fw-bold">Características</div>
      <ul class="list-group list-group-flush">
<%
    if (con != null) {
        try {
            st = con.createStatement();
            rs = st.executeQuery("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre");
            while (rs.next()) {
%>
        <li class="list-group-item d-flex justify-content-between align-items-center">
            <span><%= esc(rs.getString("nombre")) %></span>
            <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-inline"
                  onsubmit="return confirm('¿Eliminar esta característica?')">
                <input type="hidden" name="accion" value="eliminar_caracteristica">
                <input type="hidden" name="id" value="<%= rs.getInt("id_caracteristica") %>">
                <button class="btn btn-sm btn-outline-danger">&times;</button>
            </form>
        </li>
<%
            }
            cerrar(rs, st);
        } catch (SQLException ex) { %>
        <li class="list-group-item text-danger small">Error: <%= esc(ex.getMessage()) %></li>
<%      }
    }
%>
      </ul>
      <div class="card-body">
        <form method="post" action="<%= ctx %>/admin/acciones_catalogo.jsp" class="d-flex gap-2">
            <input type="hidden" name="accion" value="agregar_caracteristica">
            <input type="text" name="nombre" class="form-control form-control-sm" placeholder="Nombre" required>
            <button class="btn btn-sm btn-warning fw-bold text-nowrap">+</button>
        </form>
      </div>
    </div>
  </div>
</div>
<%
    cerrar(con);
%>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
