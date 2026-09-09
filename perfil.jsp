<%--
  perfil.jsp - Ver y editar el perfil (1:1) del usuario en sesion.
  Cualquier rol autenticado tiene perfil (se crea en registrar.jsp), asi
  que esta pagina no se restringe solo a CLIENTE.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"CLIENTE", "INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Mi perfil";
    String err = request.getParameter("err");
    String msg = request.getParameter("msg");

    String documento = "", username = "", correo = "";
    String nombres = "", apellidos = "", telefono = "", direccion = "", foto = "";

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT u.documento, u.username, u.correo, "
          + "       pf.nombres, pf.apellidos, pf.telefono, pf.direccion, pf.foto "
          + "FROM usuario u INNER JOIN perfil pf ON pf.id_usuario = u.id_usuario "
          + "WHERE u.id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) {
            documento = rs.getString("documento");
            username  = rs.getString("username");
            correo    = rs.getString("correo");
            nombres   = rs.getString("nombres");
            apellidos = rs.getString("apellidos");
            telefono  = rs.getString("telefono");
            direccion = rs.getString("direccion");
            foto      = rs.getString("foto");
        }
        cerrar(rs, ps, con);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3">Mi perfil</h3>

<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>

<div class="card shadow-sm">
<div class="card-body">
  <div class="row g-3 mb-3">
    <div class="col-md-4">
      <label class="form-label text-muted">Documento</label>
      <input class="form-control" value="<%= esc(documento) %>" disabled>
    </div>
    <div class="col-md-4">
      <label class="form-label text-muted">Usuario</label>
      <input class="form-control" value="<%= esc(username) %>" disabled>
    </div>
    <div class="col-md-4">
      <label class="form-label text-muted">Correo</label>
      <input class="form-control" value="<%= esc(correo) %>" disabled>
    </div>
  </div>

  <form method="post" action="<%= ctx %>/guardar_perfil.jsp">
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label">Nombres</label>
        <input class="form-control" name="nombres" required maxlength="80" value="<%= esc(nombres) %>">
      </div>
      <div class="col-md-6">
        <label class="form-label">Apellidos</label>
        <input class="form-control" name="apellidos" required maxlength="80" value="<%= esc(apellidos) %>">
      </div>
      <div class="col-md-4">
        <label class="form-label">Teléfono</label>
        <input class="form-control" name="telefono" maxlength="20" value="<%= esc(telefono) %>">
      </div>
      <div class="col-md-8">
        <label class="form-label">Dirección</label>
        <input class="form-control" name="direccion" maxlength="150" value="<%= esc(direccion) %>">
      </div>
      <div class="col-12">
        <label class="form-label">Foto (URL)</label>
        <input class="form-control" name="foto" maxlength="255" value="<%= esc(foto) %>"
               placeholder="URL de una imagen (sin subida real de archivos)">
      </div>
    </div>
    <div class="mt-4">
      <button class="btn btn-warning fw-bold">Guardar cambios</button>
    </div>
  </form>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
