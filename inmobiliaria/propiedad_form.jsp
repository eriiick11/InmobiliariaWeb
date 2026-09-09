<%--
  inmobiliaria/propiedad_form.jsp - Formulario de creacion y edicion de
  propiedades. Si llega ?id=X carga los datos existentes (validando que
  pertenezca a la inmobiliaria en sesion); si no, formulario vacio.
  Tambien administra la galeria de imagenes (1:N) y las caracteristicas (N:M).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<%
    String tituloPagina = "Propiedad";
    int idPropiedad = aEntero(request.getParameter("id"), 0);
    boolean esEdicion = idPropiedad > 0;
    String err = request.getParameter("err");
    String msg = request.getParameter("msg");

    int idInmobiliaria = 0;
    // Valores del formulario (vacios si es creacion)
    String matricula = "", titulo = "", descripcion = "", direccion = "", estado = "DISPONIBLE";
    double precio = 0, area = 0;
    int idTipoSel = 0, idCiudadSel = 0;

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        con = abrirConexion();

        ps = con.prepareStatement("SELECT id_inmobiliaria FROM inmobiliaria WHERE id_usuario = ?");
        ps.setInt(1, idUsuarioSesion);
        rs = ps.executeQuery();
        if (rs.next()) idInmobiliaria = rs.getInt("id_inmobiliaria");
        cerrar(rs, ps);

        if (esEdicion) {
            ps = con.prepareStatement(
                "SELECT matricula_inmobiliaria, titulo, descripcion, precio, area, direccion, "
              + "       estado, id_tipo_propiedad, id_ciudad, id_inmobiliaria "
              + "FROM propiedad WHERE id_propiedad = ?");
            ps.setInt(1, idPropiedad);
            rs = ps.executeQuery();
            if (rs.next()) {
                // Seguridad: que la propiedad sea de esta inmobiliaria
                if (rs.getInt("id_inmobiliaria") != idInmobiliaria) {
                    cerrar(rs, ps, con);
                    response.sendRedirect(ctx + "/acceso-denegado.jsp");
                    return;
                }
                matricula   = rs.getString("matricula_inmobiliaria");
                titulo      = rs.getString("titulo");
                descripcion = rs.getString("descripcion");
                precio      = rs.getDouble("precio");
                area        = rs.getDouble("area");
                direccion   = rs.getString("direccion");
                estado      = rs.getString("estado");
                idTipoSel   = rs.getInt("id_tipo_propiedad");
                idCiudadSel = rs.getInt("id_ciudad");
            } else {
                cerrar(rs, ps, con);
                response.sendRedirect(ctx + "/inmobiliaria/propiedades.jsp?err="
                    + java.net.URLEncoder.encode("La propiedad no existe.", "UTF-8"));
                return;
            }
            cerrar(rs, ps);
        }
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<h3 class="mb-3"><%= esEdicion ? "Editar propiedad" : "Nueva propiedad" %></h3>

<% if (err != null) { %><div class="alert alert-danger"><%= esc(err) %></div><% } %>
<% if (msg != null) { %><div class="alert alert-success"><%= esc(msg) %></div><% } %>

<div class="card shadow-sm mb-4">
<div class="card-body">
<form method="post" action="<%= ctx %>/inmobiliaria/guardar_propiedad.jsp">
    <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
    <div class="row g-3">
        <div class="col-md-4">
            <label class="form-label">Matricula inmobiliaria</label>
            <input class="form-control" name="matricula_inmobiliaria" required maxlength="30"
                   value="<%= esc(matricula) %>">
        </div>
        <div class="col-md-8">
            <label class="form-label">Titulo</label>
            <input class="form-control" name="titulo" required maxlength="120"
                   value="<%= esc(titulo) %>">
        </div>
        <div class="col-12">
            <label class="form-label">Descripcion</label>
            <textarea class="form-control" name="descripcion" rows="3"><%= esc(descripcion) %></textarea>
        </div>
        <div class="col-md-3">
            <label class="form-label">Tipo</label>
            <select class="form-select" name="id_tipo_propiedad" required>
                <option value="">-- Seleccione --</option>
<%
        try {
            Statement st = con.createStatement();
            ResultSet rsTipo = st.executeQuery("SELECT id_tipo_propiedad, nombre FROM tipo_propiedad ORDER BY nombre");
            while (rsTipo.next()) {
                int id = rsTipo.getInt("id_tipo_propiedad");
%>
                <option value="<%= id %>" <%= id == idTipoSel ? "selected" : "" %>>
                    <%= esc(rsTipo.getString("nombre")) %></option>
<%          }
            cerrar(rsTipo, st);
        } catch (SQLException ex) { out.println("<option>Error</option>"); }
%>
            </select>
        </div>
        <div class="col-md-3">
            <label class="form-label">Ciudad</label>
            <select class="form-select" name="id_ciudad" required>
                <option value="">-- Seleccione --</option>
<%
        try {
            Statement st2 = con.createStatement();
            ResultSet rsCiu = st2.executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
            while (rsCiu.next()) {
                int id = rsCiu.getInt("id_ciudad");
%>
                <option value="<%= id %>" <%= id == idCiudadSel ? "selected" : "" %>>
                    <%= esc(rsCiu.getString("nombre")) %></option>
<%          }
            cerrar(rsCiu, st2);
        } catch (SQLException ex) { out.println("<option>Error</option>"); }
%>
            </select>
        </div>
        <div class="col-md-2">
            <label class="form-label">Precio</label>
            <input type="number" class="form-control" name="precio" min="0" step="1000" required
                   value="<%= precio > 0 ? String.valueOf((long) precio) : "" %>">
        </div>
        <div class="col-md-2">
            <label class="form-label">Area (m2)</label>
            <input type="number" class="form-control" name="area" min="0" step="0.1"
                   value="<%= area > 0 ? area : "" %>">
        </div>
        <div class="col-md-2">
            <label class="form-label">Estado</label>
            <select class="form-select" name="estado">
                <% String[] estados = {"DISPONIBLE","VENDIDO","ARRENDADO","INACTIVO"}; %>
                <% for (String e : estados) { %>
                <option value="<%= e %>" <%= e.equals(estado) ? "selected" : "" %>><%= e %></option>
                <% } %>
            </select>
        </div>
        <div class="col-12">
            <label class="form-label">Direccion</label>
            <input class="form-control" name="direccion" maxlength="150" value="<%= esc(direccion) %>">
        </div>
    </div>
    <div class="mt-4">
        <button class="btn btn-warning fw-bold">Guardar propiedad</button>
        <a href="<%= ctx %>/inmobiliaria/propiedades.jsp" class="btn btn-link">Volver</a>
    </div>
</form>
</div>
</div>

<% if (esEdicion) { %>
<!-- ==================== GALERIA DE IMAGENES ==================== -->
<div class="card shadow-sm mb-4">
<div class="card-header bg-white fw-bold">Galeria de imagenes</div>
<div class="card-body">
    <div class="row g-3 mb-3">
<%
    try {
        ps = con.prepareStatement(
            "SELECT id_imagen, url_imagen, orden FROM imagen_propiedad "
          + "WHERE id_propiedad = ? ORDER BY orden");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        while (rs.next()) {
%>
        <div class="col-md-3">
            <div class="card">
                <img src="<%= esc(rs.getString("url_imagen")) %>" class="card-img-top"
                     style="height:120px;object-fit:cover"
                     onerror="this.src='https://via.placeholder.com/300x120?text=Sin+imagen'">
                <div class="card-body p-2 text-center">
                    <form method="post" action="<%= ctx %>/inmobiliaria/acciones_propiedad.jsp"
                          onsubmit="return confirm('Quitar esta imagen?')">
                        <input type="hidden" name="accion" value="quitar_imagen">
                        <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
                        <input type="hidden" name="id_imagen" value="<%= rs.getInt("id_imagen") %>">
                        <button class="btn btn-sm btn-outline-danger w-100">Quitar</button>
                    </form>
                </div>
            </div>
        </div>
<%      }
        cerrar(rs, ps);
    } catch (SQLException ex) {
        out.println("<div class='text-danger'>" + esc(ex.getMessage()) + "</div>");
    }
%>
    </div>
    <form method="post" action="<%= ctx %>/inmobiliaria/acciones_propiedad.jsp" class="row g-2">
        <input type="hidden" name="accion" value="agregar_imagen">
        <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
        <div class="col-md-8">
            <input class="form-control" name="url_imagen" required maxlength="255"
                   placeholder="/img/propiedades/mi0001_3.jpg o URL completa">
        </div>
        <div class="col-md-2">
            <input type="number" class="form-control" name="orden" value="1" min="1">
        </div>
        <div class="col-md-2 d-grid">
            <button class="btn btn-outline-dark">Agregar</button>
        </div>
    </form>
</div>
</div>

<!-- ==================== CARACTERISTICAS ==================== -->
<div class="card shadow-sm mb-4">
<div class="card-header bg-white fw-bold">Caracteristicas</div>
<div class="card-body">
<div class="row g-2">
<%
    try {
        // Trae todas las caracteristicas del catalogo, marcando cuales
        // ya estan asociadas a esta propiedad (LEFT JOIN)
        ps = con.prepareStatement(
            "SELECT c.id_caracteristica, c.nombre, pc.cantidad "
          + "FROM caracteristica c "
          + "LEFT JOIN propiedad_caracteristica pc "
          + "  ON pc.id_caracteristica = c.id_caracteristica AND pc.id_propiedad = ? "
          + "ORDER BY c.nombre");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        while (rs.next()) {
            boolean asignada = rs.getObject("cantidad") != null;
%>
    <div class="col-md-3">
        <form method="post" action="<%= ctx %>/inmobiliaria/acciones_propiedad.jsp"
              class="d-flex align-items-center gap-2">
            <input type="hidden" name="accion" value="toggle_caracteristica">
            <input type="hidden" name="id_propiedad" value="<%= idPropiedad %>">
            <input type="hidden" name="id_caracteristica" value="<%= rs.getInt("id_caracteristica") %>">
            <input type="hidden" name="estaba_asignada" value="<%= asignada %>">
            <div class="form-check flex-grow-1">
                <input class="form-check-input" type="checkbox" onchange="this.form.submit()"
                       <%= asignada ? "checked" : "" %>>
                <label class="form-check-label"><%= esc(rs.getString("nombre")) %></label>
            </div>
        </form>
    </div>
<%      }
        cerrar(rs, ps);
    } catch (SQLException ex) {
        out.println("<div class='text-danger'>" + esc(ex.getMessage()) + "</div>");
    } finally { cerrar(con); }
%>
</div>
</div>
</div>
<% } %>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
