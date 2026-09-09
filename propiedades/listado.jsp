<%--
  propiedades/listado.jsp - Catalogo publico con filtros. Accesible sin
  sesion (visitante) y tambien util para el cliente logueado; no fuerza
  login porque el visitante debe poder consultar el catalogo publico.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<%
    // Sesion opcional: no se redirige a nadie, solo se lee si existe.
    Integer idUsuarioSesion = (Integer) session.getAttribute("idUsuario");
    String nombreSesion = (String) session.getAttribute("nombre");
    String rolSesion = (String) session.getAttribute("rol");
    String ctx = request.getContextPath();

    int idCiudad   = aEntero(request.getParameter("idCiudad"), 0);
    int idTipo     = aEntero(request.getParameter("idTipo"), 0);
    double precioMax = aDoble(request.getParameter("precioMax"), 0);
    String[] caracSel = request.getParameterValues("caracteristica");
    Set<Integer> caracSeleccionadas = new HashSet<Integer>();
    if (caracSel != null) {
        for (String s : caracSel) caracSeleccionadas.add(aEntero(s, -1));
    }

    StringBuilder sql = new StringBuilder(
        "SELECT p.id_propiedad, p.titulo, p.precio, p.area, p.direccion, p.estado, "
      + "       tp.nombre AS tipo, c.nombre AS ciudad, i.nombre_comercial AS inmobiliaria "
      + "FROM propiedad p "
      + "INNER JOIN tipo_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad "
      + "INNER JOIN ciudad c ON c.id_ciudad = p.id_ciudad "
      + "INNER JOIN inmobiliaria i ON i.id_inmobiliaria = p.id_inmobiliaria "
      + "WHERE p.estado = 'DISPONIBLE' ");
    if (idCiudad > 0)   sql.append("AND p.id_ciudad = ").append(idCiudad).append(" ");
    if (idTipo > 0)     sql.append("AND p.id_tipo_propiedad = ").append(idTipo).append(" ");
    if (precioMax > 0)  sql.append("AND p.precio <= ").append((long) precioMax).append(" ");
    for (Integer idc : caracSeleccionadas) {
        sql.append("AND EXISTS (SELECT 1 FROM propiedad_caracteristica pc ")
           .append("WHERE pc.id_propiedad = p.id_propiedad AND pc.id_caracteristica = ")
           .append(idc).append(") ");
    }
    sql.append("ORDER BY p.fecha_publicacion DESC");
    // Nota: los filtros llegan como enteros ya validados con aEntero/aDoble
    // (nunca texto libre concatenado), por eso no se usa PreparedStatement aqui.

    Connection con = null; Statement st = null; ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Catálogo de propiedades | Raíz</title>
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
      <span class="small text-muted"><%= esc(nombreSesion) %></span>
      <a class="btn btn-ghost" href="<%= ctx %>/logout.jsp">Cerrar sesión</a>
<% } %>
    </div>
  </div>
</header>

<section class="section">
  <div class="wrap">
    <div class="section-head">
      <h2>Catálogo de propiedades</h2>
      <p>Filtra por ciudad, tipo, precio y características.</p>
    </div>

    <form method="get" action="<%= ctx %>/propiedades/listado.jsp" class="search-panel">
      <div class="field">
        <label for="idCiudad">Ciudad</label>
        <select id="idCiudad" name="idCiudad">
          <option value="">Cualquier ciudad</option>
<%
    con = abrirConexion();
    st = con.createStatement();
    rs = st.executeQuery("SELECT id_ciudad, nombre FROM ciudad ORDER BY nombre");
    while (rs.next()) {
        int id = rs.getInt("id_ciudad");
%>
          <option value="<%= id %>" <%= id == idCiudad ? "selected" : "" %>><%= esc(rs.getString("nombre")) %></option>
<%  }
    cerrar(rs, st);
%>
        </select>
      </div>
      <div class="field">
        <label for="idTipo">Tipo</label>
        <select id="idTipo" name="idTipo">
          <option value="">Cualquier tipo</option>
<%
    st = con.createStatement();
    rs = st.executeQuery("SELECT id_tipo_propiedad, nombre FROM tipo_propiedad ORDER BY nombre");
    while (rs.next()) {
        int id = rs.getInt("id_tipo_propiedad");
%>
          <option value="<%= id %>" <%= id == idTipo ? "selected" : "" %>><%= esc(rs.getString("nombre")) %></option>
<%  }
    cerrar(rs, st);
%>
        </select>
      </div>
      <div class="field">
        <label for="precioMax">Precio máximo</label>
        <input type="number" id="precioMax" name="precioMax" min="0" step="1000000"
               value="<%= precioMax > 0 ? String.valueOf((long) precioMax) : "" %>" placeholder="Sin límite">
      </div>
      <fieldset class="field">
        <legend>Características</legend>
<%
    st = con.createStatement();
    rs = st.executeQuery("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY nombre");
    while (rs.next()) {
        int id = rs.getInt("id_caracteristica");
%>
        <label class="check-inline">
          <input type="checkbox" name="caracteristica" value="<%= id %>"
                 <%= caracSeleccionadas.contains(id) ? "checked" : "" %>>
          <%= esc(rs.getString("nombre")) %>
        </label>
<%  }
    cerrar(rs, st);
%>
      </fieldset>
      <button type="submit" class="btn btn-brass">Buscar</button>
    </form>

    <div class="listing-grid">
<%
    boolean hayResultados = false;
    try {
        st = con.createStatement();
        rs = st.executeQuery(sql.toString());
        while (rs.next()) {
            hayResultados = true;
%>
      <a class="listing-card" href="<%= ctx %>/propiedades/ficha.jsp?id=<%= rs.getInt("id_propiedad") %>">
        <div>
          <span class="listing-tag"><%= esc(rs.getString("tipo")) %></span>
          <h3><%= esc(rs.getString("titulo")) %></h3>
          <p class="listing-address"><%= esc(rs.getString("direccion")) %>, <%= esc(rs.getString("ciudad")) %></p>
        </div>
        <dl class="listing-specs">
          <div><dt>Área</dt><dd><%= rs.getDouble("area") %> m²</dd></div>
          <div><dt>Publica</dt><dd><%= esc(rs.getString("inmobiliaria")) %></dd></div>
        </dl>
        <p class="listing-price"><%= pesos(rs.getDouble("precio")) %></p>
      </a>
<%
        }
        cerrar(rs, st);
    } catch (SQLException ex) {
%>
      <div class="empty-state">Ocurrió un problema consultando el catálogo. Intenta de nuevo.</div>
<%
    } finally { cerrar(con); }
    if (!hayResultados) {
%>
      <div class="empty-state">No hay propiedades disponibles con esos filtros.</div>
<% } %>
    </div>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <a class="brand" href="<%= ctx %>/index.jsp">Ra<span>í</span>z</a>
    <p class="footer-note">Proyecto académico — UTS, Tecnología en Desarrollo de Sistemas Informáticos.</p>
  </div>
</footer>

</body>
</html>
