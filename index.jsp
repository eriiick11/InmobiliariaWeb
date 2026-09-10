<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%!
    /** Devuelve el marcado SVG de un icono de línea según el tipo de propiedad. */
    public String iconoTipo(String tipo) {
        if (tipo == null) tipo = "";
        switch (tipo) {
            case "Casa":
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><path d=\"M6 19 20 7l14 12\"/><path d=\"M9 17v14h22V17\"/><path d=\"M17 31v-9h6v9\"/></svg>";
            case "Apartamento":
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><rect x=\"10\" y=\"6\" width=\"20\" height=\"28\"/><path d=\"M15 12h2M23 12h2M15 18h2M23 18h2M15 24h2M23 24h2\"/><path d=\"M17 34v-6h6v6\"/></svg>";
            case "Local":
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><path d=\"M6 14 8 7h24l2 7\"/><path d=\"M6 14v3a3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0v-3\"/><path d=\"M8 17v16h24V17\"/></svg>";
            case "Oficina":
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><rect x=\"8\" y=\"6\" width=\"24\" height=\"28\"/><path d=\"M13 12h4v4h-4zM23 12h4v4h-4zM13 20h4v4h-4zM23 20h4v4h-4z\"/></svg>";
            case "Terreno":
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><path d=\"M4 28 14 16l6 7 6-10 10 15\"/><path d=\"M4 32h32\"/></svg>";
            default:
                return "<svg class=\"listing-icon\" viewBox=\"0 0 40 40\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"1.4\"><rect x=\"8\" y=\"8\" width=\"24\" height=\"24\"/></svg>";
        }
    }
%>
<%
    // ---- Datos para el formulario de búsqueda: ciudades y tipos de propiedad ----
    Connection con = null;
    Statement st = null;
    ResultSet rs = null;

    // ---- Sesion opcional: no se redirige, solo se lee si existe ----
    Integer idUsuarioSesion = (Integer) session.getAttribute("idUsuario");
    String nombreSesion = (String) session.getAttribute("nombre");
    String rolSesion = (String) session.getAttribute("rol");

    // ---- Propiedades destacadas: últimas disponibles, con ciudad/tipo/inmobiliaria y su
    //      primera foto (si tiene alguna cargada en imagen_propiedad; si no, queda null y
    //      la tarjeta muestra el icono de respaldo). Se guardan en una lista para poder
    //      reutilizar la primera también en la tarjeta flotante del hero. ----
    final String SQL_DESTACADAS =
        "SELECT p.id_propiedad, p.titulo, p.precio, p.area, p.direccion, " +
        "       tp.nombre AS tipo, c.nombre AS ciudad, i.nombre_comercial AS inmobiliaria, " +
        "       (SELECT ip.url_imagen FROM imagen_propiedad ip " +
        "         WHERE ip.id_propiedad = p.id_propiedad ORDER BY ip.orden LIMIT 1) AS foto_url " +
        "FROM propiedad p " +
        "INNER JOIN tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad " +
        "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
        "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
        "WHERE p.estado = 'DISPONIBLE' " +
        "ORDER BY p.fecha_publicacion DESC " +
        "LIMIT 6";

    List<Map<String, Object>> destacadas = new ArrayList<Map<String, Object>>();
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery(SQL_DESTACADAS);
        while (rs.next()) {
            Map<String, Object> fila = new HashMap<String, Object>();
            fila.put("id_propiedad", rs.getInt("id_propiedad"));
            fila.put("titulo", rs.getString("titulo"));
            fila.put("precio", rs.getDouble("precio"));
            fila.put("area", rs.getDouble("area"));
            fila.put("direccion", rs.getString("direccion"));
            fila.put("tipo", rs.getString("tipo"));
            fila.put("ciudad", rs.getString("ciudad"));
            fila.put("inmobiliaria", rs.getString("inmobiliaria"));
            fila.put("foto_url", rs.getString("foto_url"));
            destacadas.add(fila);
        }
%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Raíz — Encuentra dónde establecerte</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Work+Sans:wght@400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="css/style.css">
</head>
<body>

<header class="site-header">
  <div class="wrap">
    <a class="brand" href="index.jsp">Ra<span>í</span>z</a>
    <nav class="main-nav">
      <a href="index.jsp">Inicio</a>
      <a href="propiedades/listado.jsp">Propiedades</a>
      <a href="#nosotros">Nosotros</a>
    </nav>
    <div class="nav-actions">
<% if (idUsuarioSesion == null) { %>
      <a class="btn btn-ghost" href="login.jsp">Iniciar sesión</a>
      <a class="btn btn-brass" href="registro.jsp">Crear cuenta</a>
<% } else { %>
      <span class="small" style="color:var(--ink-600);margin-right:8px">Hola, <%= nombreSesion %></span>
      <a class="btn btn-ghost" href="inicio.jsp">Mi panel</a>
      <a class="btn btn-brass" href="logout.jsp">Cerrar sesión</a>
<% } %>
    </div>
  </div>
</header>

<section class="hero">
  <div class="wrap">
    <div class="hero-copy">
      <span class="hero-eyebrow">Bucaramanga y Santander</span>
      <h1>Encuentra dónde establecerte en Santander</h1>
      <p class="hero-lead">
        Raíz conecta a personas con inmobiliarias de confianza en Bucaramanga y el resto
        del departamento. Busca, agenda una visita y da el siguiente paso sin salir de aquí.
      </p>

      <div class="search-panel">
        <form action="propiedades/listado.jsp" method="get">
          <div class="field">
            <label for="ciudad">Ciudad</label>
            <select id="ciudad" name="idCiudad">
              <option value="">Cualquier ciudad</option>
<%
        Statement stCiudad = con.createStatement();
        ResultSet rsCiudad = stCiudad.executeQuery(
            "SELECT id_ciudad, nombre, departamento FROM ciudad ORDER BY nombre");
        while (rsCiudad.next()) {
%>
              <option value="<%= rsCiudad.getInt("id_ciudad") %>">
                <%= rsCiudad.getString("nombre") %>, <%= rsCiudad.getString("departamento") %>
              </option>
<%
        }
        cerrar(rsCiudad, stCiudad);
%>
            </select>
          </div>

          <div class="field">
            <label for="tipo">Tipo de inmueble</label>
            <select id="tipo" name="idTipo">
              <option value="">Cualquier tipo</option>
<%
        Statement stTipo = con.createStatement();
        ResultSet rsTipo = stTipo.executeQuery(
            "SELECT id_tipo_propiedad, nombre FROM tipo_propiedad ORDER BY nombre");
        while (rsTipo.next()) {
%>
              <option value="<%= rsTipo.getInt("id_tipo_propiedad") %>">
                <%= rsTipo.getString("nombre") %>
              </option>
<%
        }
        cerrar(rsTipo, stTipo);
%>
            </select>
          </div>

          <div class="field">
            <label for="precioMax">Precio máximo</label>
            <input type="number" id="precioMax" name="precioMax" min="0" step="1000000" placeholder="Sin límite">
          </div>

          <button type="submit" class="btn btn-brass">Buscar</button>
        </form>
      </div>
    </div>

    <div class="hero-art">
      <div class="hero-card">
        <div class="hero-card-photo">
<%
    if (!destacadas.isEmpty() && destacadas.get(0).get("foto_url") != null) {
        Map<String, Object> primera = destacadas.get(0);
%>
          <img src="<%= primera.get("foto_url") %>" alt="<%= primera.get("titulo") %>">
<%
    } else {
        out.print(iconoTipo(destacadas.isEmpty() ? "" : (String) destacadas.get(0).get("tipo")));
    }
%>
        </div>
<%
    if (!destacadas.isEmpty()) {
        Map<String, Object> primera = destacadas.get(0);
%>
        <p><%= primera.get("titulo") %></p>
        <span><%= primera.get("ciudad") %> · $ <%= String.format("%,.0f", (Double) primera.get("precio")) %></span>
<%
    } else {
%>
        <p>Tu próxima propiedad</p>
        <span>Publicada por una inmobiliaria aliada</span>
<%  } %>
      </div>
    </div>
  </div>
</section>

<section class="section" id="destacadas">
  <div class="wrap">
    <div class="section-head">
      <h2>Publicaciones destacadas</h2>
      <p>Las incorporaciones más recientes de nuestras inmobiliarias aliadas.</p>
    </div>

    <div class="listing-grid">
<%
        if (destacadas.isEmpty()) {
%>
      <div class="empty-state">
        Todavía no hay propiedades disponibles publicadas. Vuelve pronto.
      </div>
<%
        }
        for (Map<String, Object> prop : destacadas) {
            String tipo = (String) prop.get("tipo");
            String fotoUrl = (String) prop.get("foto_url");
%>
      <a class="listing-card" href="propiedades/ficha.jsp?id=<%= prop.get("id_propiedad") %>">
        <div class="listing-photo">
          <span class="listing-tag"><%= tipo %></span>
<%
            if (fotoUrl != null) {
%>
          <img src="<%= fotoUrl %>" alt="<%= prop.get("titulo") %>">
<%
            } else {
%>
          <span class="listing-icon-fallback"><%= iconoTipo(tipo) %></span>
<%
            }
%>
        </div>
        <div class="listing-body">
          <div>
            <h3><%= prop.get("titulo") %></h3>
            <p class="listing-address"><%= prop.get("direccion") %>, <%= prop.get("ciudad") %></p>
          </div>
          <dl class="listing-specs">
            <div>
              <dt>Área</dt>
              <dd><%= prop.get("area") %> m²</dd>
            </div>
            <div>
              <dt>Publica</dt>
              <dd><%= prop.get("inmobiliaria") %></dd>
            </div>
          </dl>
          <p class="listing-price">
            $ <%= String.format("%,.0f", (Double) prop.get("precio")) %>
          </p>
        </div>
      </a>
<%
        }
%>
    </div>

    <p style="text-align:center;margin-top:32px">
      <a class="btn btn-ghost" href="propiedades/listado.jsp">Ver todo el catálogo</a>
    </p>
  </div>
</section>

<section class="section features" id="nosotros">
  <div class="wrap">
    <div class="section-head">
      <h2>Por qué Raíz</h2>
      <p>Pensado para que cada trámite quede en un solo lugar.</p>
    </div>

    <div class="feature-grid">
      <div class="feature">
        <h3>Explora sin registrarte</h3>
        <p>Consulta el catálogo completo y el detalle de cada inmueble antes de crear tu cuenta.</p>
      </div>
      <div class="feature">
        <h3>Agenda y da seguimiento a tus trámites</h3>
        <p>Solicita visitas, radica documentos y consulta el estado de tus solicitudes desde tu panel de cliente.</p>
      </div>
      <div class="feature">
        <h3>Administra tu catálogo como inmobiliaria</h3>
        <p>Publica propiedades, gestiona la galería de imágenes y responde solicitudes en un solo lugar.</p>
      </div>
    </div>
  </div>
</section>

<section class="cta-band">
  <div class="wrap">
<% if (idUsuarioSesion == null) { %>
    <h2>¿Listo para encontrar tu próximo lugar?</h2>
    <p>Crea tu cuenta gratis y guarda tus propiedades favoritas.</p>
    <a class="btn btn-brass" href="registro.jsp">Crear cuenta</a>
<% } else { %>
    <h2>Sigue explorando el catálogo</h2>
    <p>Encuentra tu próxima propiedad y agenda una visita.</p>
    <a class="btn btn-brass" href="propiedades/listado.jsp">Ver propiedades</a>
<% } %>
  </div>
</section>

<footer class="site-footer">
  <div class="wrap">
    <a class="brand" href="index.jsp">Ra<span>í</span>z</a>
    <p class="footer-note">Proyecto académico — UTS, Tecnología en Desarrollo de Sistemas Informáticos.</p>
  </div>
</footer>

</body>
</html>
<%
    } catch (SQLException ex) {
%>
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Raíz</title></head>
<body>
  <h1>No fue posible cargar la página</h1>
  <p>Ocurrió un problema consultando la base de datos. Intenta de nuevo en unos minutos.</p>
<%
        // Para depuración durante el desarrollo; quitar o loguear en producción.
        out.println("<!-- " + ex.getMessage() + " -->");
    } finally {
        cerrar(rs, st, con);
    }
%>
