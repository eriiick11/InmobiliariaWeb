<%--
  propiedades/ficha.jsp - Detalle publico de una propiedad. Accesible sin
  sesion (visitante). Si hay sesion de CLIENTE se deja el punto de enganche
  para "agendar cita" y "favorito", que se conectan en los pasos 3 y 4.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    Integer idUsuarioSesion = (Integer) session.getAttribute("idUsuario");
    String rolSesion = (String) session.getAttribute("rol");
    String ctx = request.getContextPath();

    int idPropiedad = aEntero(request.getParameter("id"), 0);

    Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
    boolean encontrada = false;
    String titulo = "", descripcion = "", direccion = "", tipo = "", ciudad = "", inmobiliaria = "", estado = "";
    double precio = 0, area = 0;
    try {
        con = abrirConexion();
        ps = con.prepareStatement(
            "SELECT p.titulo, p.descripcion, p.precio, p.area, p.direccion, p.estado, "
          + "       tp.nombre AS tipo, c.nombre AS ciudad, i.nombre_comercial AS inmobiliaria "
          + "FROM propiedad p "
          + "INNER JOIN tipo_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad "
          + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
          + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
          + "WHERE p.id_propiedad = ? AND p.estado != 'INACTIVO'");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        if (rs.next()) {
            encontrada = true;
            titulo = rs.getString("titulo");
            descripcion = rs.getString("descripcion");
            precio = rs.getDouble("precio");
            area = rs.getDouble("area");
            direccion = rs.getString("direccion");
            estado = rs.getString("estado");
            tipo = rs.getString("tipo");
            ciudad = rs.getString("ciudad");
            inmobiliaria = rs.getString("inmobiliaria");
        }
        cerrar(rs, ps);
    } catch (SQLException ex) {
        request.setAttribute("errorBD", ex.getMessage());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= encontrada ? esc(titulo) : "Propiedad" %> | Raíz</title>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Work+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="brand" href="<%= ctx %>/index.jsp">Ra<span>í</span>z</a>
    <nav class="main-nav">
      <a href="<%= ctx %>/index.jsp">Inicio</a>
      <a href="<%= ctx %>/propiedades/listado.jsp">Propiedades</a>
    </nav>
    <div class="nav-actions">
<% if (idUsuarioSesion == null) { %>
      <a class="btn btn-ghost" href="<%= ctx %>/login.jsp">Iniciar sesión</a>
      <a class="btn btn-brass" href="<%= ctx %>/registro.jsp">Crear cuenta</a>
<% } else { %>
      <a class="btn btn-ghost" href="<%= ctx %>/logout.jsp">Cerrar sesión</a>
<% } %>
    </div>
  </div>
</header>

<section class="section">
  <div class="wrap">
<% if (!encontrada) { %>
    <div class="empty-state">Esta propiedad no existe o ya no está disponible.
      <a href="<%= ctx %>/propiedades/listado.jsp">Volver al catálogo</a></div>
<% } else { %>
    <span class="listing-tag"><%= esc(tipo) %></span>
    <h2><%= esc(titulo) %></h2>
    <p class="listing-address"><%= esc(direccion) %>, <%= esc(ciudad) %></p>
    <p class="listing-price"><%= pesos(precio) %> — <%= area %> m² — <%= esc(estado) %></p>
    <p><%= esc(descripcion) %></p>

    <h3>Galería</h3>
    <div class="listing-grid">
<%
    boolean hayImagenes = false;
    try {
        ps = con.prepareStatement(
            "SELECT url_imagen FROM imagen_propiedad WHERE id_propiedad = ? ORDER BY orden");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        while (rs.next()) {
            hayImagenes = true;
%>
      <img src="<%= esc(rs.getString("url_imagen")) %>" alt="Foto de <%= esc(titulo) %>"
           style="width:100%;height:180px;object-fit:cover;border-radius:8px"
           onerror="this.src='https://via.placeholder.com/300x180?text=Sin+imagen'">
<%      }
        cerrar(rs, ps);
    } catch (SQLException ex) { /* si falla, simplemente no se muestran fotos */ }
    if (!hayImagenes) {
%>
      <p class="text-muted">Esta propiedad todavía no tiene fotos.</p>
<% } %>
    </div>

    <h3>Características</h3>
    <ul>
<%
    boolean hayCaracteristicas = false;
    try {
        ps = con.prepareStatement(
            "SELECT c.nombre FROM propiedad_caracteristica pc "
          + "INNER JOIN caracteristica c ON c.id_caracteristica = pc.id_caracteristica "
          + "WHERE pc.id_propiedad = ? ORDER BY c.nombre");
        ps.setInt(1, idPropiedad);
        rs = ps.executeQuery();
        while (rs.next()) {
            hayCaracteristicas = true;
%>
      <li><%= esc(rs.getString("nombre")) %></li>
<%      }
        cerrar(rs, ps);
    } catch (SQLException ex) { /* ignorado, ver comentario de arriba */ }
    if (!hayCaracteristicas) {
%>
      <li class="text-muted">Sin características registradas.</li>
<% } %>
    </ul>

    <h3>Publica</h3>
    <p><%= esc(inmobiliaria) %></p>
<%
    // Visitante: no ve datos de contacto completos ni puede agendar/favoritos.
    if (idUsuarioSesion == null) {
%>
    <p class="text-muted">Inicia sesión como cliente para ver el contacto completo,
       agendar una visita y guardarla en tus favoritos.</p>
<%
    } else if ("CLIENTE".equals(rolSesion)) {
%>
    <p class="text-muted">Agendar visita y marcar como favorito se habilitan en los
       siguientes pasos del proyecto (citas y favoritos).</p>
<% } %>
<% } %>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <a class="brand" href="<%= ctx %>/index.jsp">Ra<span>í</span>z</a>
    <p class="footer-note">Proyecto académico — UTS, Tecnología en Desarrollo de Sistemas Informáticos.</p>
  </div>
</footer>
<% cerrar(con); %>
</body>
</html>
