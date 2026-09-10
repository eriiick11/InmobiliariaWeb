<%--
  admin/usuarios.jsp - Lista todos los usuarios del sistema con sus roles
  (relacion N:M via usuario_rol) y su estado de cuenta. Permite asignar o
  revocar un rol, y activar/inactivar la cuenta, mediante acciones_usuario.jsp.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Usuarios";
    String msg = request.getParameter("msg");
    String err = request.getParameter("err");
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<div class="d-flex justify-content-between align-items-center mb-3">
    <h3 class="mb-0">Usuarios del sistema</h3>
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

<div class="card shadow-sm">
<div class="table-responsive">
<table class="table table-hover align-middle mb-0">
    <thead class="table-dark">
        <tr>
            <th>Usuario</th><th>Nombre</th><th>Correo</th>
            <th>Roles</th><th>Estado</th><th class="text-end">Acciones</th>
        </tr>
    </thead>
    <tbody>
<%
    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    Statement stRoles = null; ResultSet rsRoles = null;
    int filas = 0;
    // Mapa id_rol -> nombre, para el select de "asignar rol"
    LinkedHashMap<Integer, String> catalogoRoles = new LinkedHashMap<Integer, String>();
    try {
        con = abrirConexion();

        stRoles = con.createStatement();
        rsRoles = stRoles.executeQuery("SELECT id_rol, nombre FROM rol ORDER BY nombre");
        while (rsRoles.next()) catalogoRoles.put(rsRoles.getInt("id_rol"), rsRoles.getString("nombre"));
        cerrar(rsRoles, stRoles);

        ps = con.prepareStatement(
            "SELECT u.id_usuario, u.username, u.correo, u.activo, "
          + "       p.nombres, p.apellidos "
          + "FROM usuario u LEFT JOIN perfil p ON p.id_usuario = u.id_usuario "
          + "ORDER BY u.id_usuario");
        rs = ps.executeQuery();
        while (rs.next()) {
            filas++;
            int idUsuario = rs.getInt("id_usuario");
            boolean activo = rs.getBoolean("activo");
            String nombreCompleto = (rs.getString("nombres") == null ? "" : rs.getString("nombres"))
                + " " + (rs.getString("apellidos") == null ? "" : rs.getString("apellidos"));

            // Roles actuales de este usuario (N:M via usuario_rol)
            PreparedStatement psr = con.prepareStatement(
                "SELECT r.id_rol, r.nombre FROM usuario_rol ur "
              + "JOIN rol r ON r.id_rol = ur.id_rol WHERE ur.id_usuario = ? ORDER BY r.nombre");
            psr.setInt(1, idUsuario);
            ResultSet rsr = psr.executeQuery();
            List<Integer> idsRolActual = new ArrayList<Integer>();
%>
        <tr>
            <td><code><%= esc(rs.getString("username")) %></code></td>
            <td><%= esc(nombreCompleto.trim().isEmpty() ? "(sin perfil)" : nombreCompleto) %></td>
            <td class="small text-muted"><%= esc(rs.getString("correo")) %></td>
            <td>
<%
            while (rsr.next()) {
                idsRolActual.add(rsr.getInt("id_rol"));
%>
                <span class="badge text-bg-secondary me-1"><%= esc(rsr.getString("nombre")) %>
                    <a href="#" class="text-white text-decoration-none"
                       onclick="if(confirm('¿Revocar el rol <%= esc(rsr.getString("nombre")) %>?')){
                                document.getElementById('frmRevocar<%= idUsuario %>_<%= rsr.getInt("id_rol") %>').submit();}
                                return false;">&times;</a>
                </span>
                <form id="frmRevocar<%= idUsuario %>_<%= rsr.getInt("id_rol") %>" method="post"
                      action="<%= ctx %>/admin/acciones_usuario.jsp" class="d-none">
                    <input type="hidden" name="accion" value="revocar_rol">
                    <input type="hidden" name="id_usuario" value="<%= idUsuario %>">
                    <input type="hidden" name="id_rol" value="<%= rsr.getInt("id_rol") %>">
                </form>
<%          }
            cerrar(rsr, psr);
%>
            </td>
            <td>
                <% if (activo) { %>
                    <span class="badge text-bg-success">Activo</span>
                <% } else { %>
                    <span class="badge text-bg-secondary">Inactivo</span>
                <% } %>
            </td>
            <td class="text-end">
                <form method="post" action="<%= ctx %>/admin/acciones_usuario.jsp" class="d-inline-flex gap-1">
                    <input type="hidden" name="accion" value="asignar_rol">
                    <input type="hidden" name="id_usuario" value="<%= idUsuario %>">
                    <select name="id_rol" class="form-select form-select-sm" style="width:auto;display:inline-block">
<%
                for (Map.Entry<Integer, String> rEntry : catalogoRoles.entrySet()) {
                    if (!idsRolActual.contains(rEntry.getKey())) {
%>
                        <option value="<%= rEntry.getKey() %>"><%= esc(rEntry.getValue()) %></option>
<%                  }
                }
%>
                    </select>
                    <button class="btn btn-sm btn-outline-dark">+ Asignar</button>
                </form>
                <form method="post" action="<%= ctx %>/admin/acciones_usuario.jsp" class="d-inline"
                      onsubmit="return confirm('<%= activo ? "¿Inactivar" : "¿Activar" %> esta cuenta?')">
                    <input type="hidden" name="accion" value="<%= activo ? "inactivar" : "activar" %>">
                    <input type="hidden" name="id_usuario" value="<%= idUsuario %>">
                    <button class="btn btn-sm <%= activo ? "btn-outline-danger" : "btn-outline-success" %>">
                        <%= activo ? "Inactivar" : "Activar" %></button>
                </form>
            </td>
        </tr>
<%
        }
    } catch (SQLException ex) {
%>
        <tr><td colspan="6" class="text-danger">Error: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally { cerrar(rs, ps, con); }
    if (filas == 0) {
%>
        <tr><td colspan="6" class="text-center text-muted py-4">No hay usuarios registrados.</td></tr>
<% } %>
    </tbody>
</table>
</div>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
