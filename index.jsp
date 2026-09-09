<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
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

    // ---- Propiedades destacadas: últimas disponibles, con ciudad/tipo/inmobiliaria ----
    final String SQL_DESTACADAS =
        "SELECT p.id_propiedad, p.titulo, p.precio, p.area, p.direccion, " +
        "       tp.nombre AS tipo, c.nombre AS ciudad, i.nombre_comercial AS inmobiliaria " +
        "FROM propiedad p " +
        "INNER JOIN tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad " +
        "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad " +
        "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria " +
        "WHERE p.estado = 'DISPONIBLE' " +
        "ORDER BY p.fecha_publicacion DESC " +
        "LIMIT 6";

    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery(SQL_DESTACADAS);
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
      <a href="#destacadas">Propiedades</a>
      <a href="#nosotros">Nosotros</a>
    </nav>
    <div class="nav-actions">
      <a class="btn btn-ghost" href="login.jsp">Iniciar sesión</a>
      <a class="btn btn-brass" href="registro.jsp">Crear cuenta</a>
    </div>
  </div>
</header>

<section class="hero">
  <div class="wrap">
    <div class="hero-copy">
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

    <div class="hero-art" aria-hidden="true">
      <svg viewBox="0 0 320 340" fill="none" stroke="#CBA646" stroke-width="1.2">
        <path d="M20 200 160 40 300 200"/>
        <path d="M45 190v130h230V190"/>
        <path d="M130 320v-90h60v90"/>
        <path d="M75 220h30v30H75zM215 220h30v30h-30z"/>
        <path d="M160 40v-25" stroke-dasharray="3 4"/>
        <circle cx="160" cy="10" r="4"/>
      </svg>
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
        boolean hayDestacadas = false;
        while (rs.next()) {
            hayDestacadas = true;
            String tipo = rs.getString("tipo");
%>
      <article class="listing-card">
        <%= iconoTipo(tipo) %>
        <div>
          <span class="listing-tag"><%= tipo %></span>
          <h3><%= rs.getString("titulo") %></h3>
          <p class="listing-address"><%= rs.getString("direccion") %>, <%= rs.getString("ciudad") %></p>
        </div>
        <dl class="listing-specs">
          <div>
            <dt>Área</dt>
            <dd><%= rs.getDouble("area") %> m²</dd>
          </div>
          <div>
            <dt>Publica</dt>
            <dd><%= rs.getString("inmobiliaria") %></dd>
          </div>
        </dl>
        <p class="listing-price">
          $ <%= String.format("%,.0f", rs.getDouble("precio")) %>
        </p>
      </article>
<%
        }
        if (!hayDestacadas) {
%>
      <div class="empty-state">
        Todavía no hay propiedades disponibles publicadas. Vuelve pronto.
      </div>
<%
        }
%>
    </div>
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
    <h2>¿Listo para encontrar tu próximo lugar?</h2>
    <p>Crea tu cuenta gratis y guarda tus propiedades favoritas.</p>
    <a class="btn btn-brass" href="registro.jsp">Crear cuenta</a>
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
