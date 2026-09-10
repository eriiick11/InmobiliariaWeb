<%--
  reportes.jsp - Reportes con SQL (paso 12). Ejecuta las 5 consultas
  obligatorias + las 2 variantes ya escritas en 03_consultas_inmobiliaria.sql,
  sin modificarlas. Solo lectura: no necesita controlador de accion aparte.
  Compartido entre ADMINISTRADOR e INMOBILIARIA (mismo patron de perfil.jsp).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR", "INMOBILIARIA"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% String tituloPagina = "Reportes"; %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>

<%
    int r = aEntero(request.getParameter("r"), 1);

    String sql;
    switch (r) {
        case 2:
            sql = "SELECT ci.id_cita, ci.fecha_hora, ci.estado AS estado_cita, "
                + "       p.titulo AS propiedad, p.direccion, u.correo, "
                + "       pf.nombres, pf.apellidos, pf.telefono "
                + "FROM cita ci "
                + "INNER JOIN propiedad p ON ci.id_propiedad = p.id_propiedad "
                + "INNER JOIN usuario u ON ci.id_cliente = u.id_usuario "
                + "INNER JOIN perfil pf ON u.id_usuario = pf.id_usuario "
                + "ORDER BY ci.fecha_hora";
            break;
        case 3:
            sql = "SELECT p.id_propiedad, p.titulo, car.nombre AS caracteristica, pc.cantidad "
                + "FROM propiedad p "
                + "INNER JOIN propiedad_caracteristica pc ON p.id_propiedad = pc.id_propiedad "
                + "INNER JOIN caracteristica car ON pc.id_caracteristica = car.id_caracteristica "
                + "ORDER BY p.titulo, car.nombre";
            break;
        case 4:
            sql = "SELECT u.id_usuario, u.username, r.nombre AS rol, ur.fecha_asignacion "
                + "FROM usuario u "
                + "INNER JOIN usuario_rol ur ON u.id_usuario = ur.id_usuario "
                + "INNER JOIN rol r ON ur.id_rol = r.id_rol "
                + "ORDER BY u.username";
            break;
        case 5:
            sql = "SELECT p.id_propiedad, p.titulo, p.estado, ci.id_cita "
                + "FROM propiedad p "
                + "LEFT JOIN cita ci ON p.id_propiedad = ci.id_propiedad "
                + "WHERE ci.id_cita IS NULL";
            break;
        case 6:
            sql = "SELECT c.nombre AS ciudad, COUNT(p.id_propiedad) AS total_disponibles, "
                + "       AVG(p.precio) AS precio_promedio "
                + "FROM propiedad p "
                + "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad "
                + "WHERE p.estado = 'DISPONIBLE' "
                + "GROUP BY c.nombre "
                + "HAVING COUNT(p.id_propiedad) > 1 "
                + "ORDER BY total_disponibles DESC";
            break;
        case 7:
            sql = "SELECT estado AS estado_cita, COUNT(*) AS total "
                + "FROM cita "
                + "GROUP BY estado "
                + "HAVING COUNT(*) >= 1 "
                + "ORDER BY total DESC";
            break;
        case 1:
        default:
            r = 1;
            sql = "SELECT p.id_propiedad, p.titulo, p.precio, p.estado, "
                + "       tp.nombre AS tipo_propiedad, c.nombre AS ciudad, c.departamento, "
                + "       i.nombre_comercial AS inmobiliaria "
                + "FROM propiedad p "
                + "INNER JOIN tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad "
                + "INNER JOIN ciudad c ON p.id_ciudad = c.id_ciudad "
                + "INNER JOIN inmobiliaria i ON p.id_inmobiliaria = i.id_inmobiliaria "
                + "ORDER BY c.nombre, p.titulo";
    }

    Connection con = null; Statement st = null; ResultSet rs = null;
%>

<div class="page-header">
  <div class="page-icon"><i class="bi bi-bar-chart"></i></div>
  <div>
    <h1>Reportes</h1>
    <p>Las 5 consultas SQL obligatorias del parcial (2 INNER JOIN con 3+ tablas,
       1 relación N:M, 1 LEFT JOIN, 1 GROUP BY + HAVING), más las 2 variantes,
       ejecutadas en vivo contra la base de datos.</p>
  </div>
</div>

<ul class="nav nav-pills mb-3 flex-wrap">
  <li class="nav-item"><a class="nav-link <%= r==1?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=1">1. Propiedades (ciudad/tipo/inmobiliaria)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==2?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=2">2. Citas (propiedad/cliente)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==3?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=3">3. Características por propiedad (N:M)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==4?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=4">3b. Roles por usuario (N:M)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==5?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=5">4. Propiedades sin citas (LEFT JOIN)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==6?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=6">5. Disponibles por ciudad (GROUP BY+HAVING)</a></li>
  <li class="nav-item"><a class="nav-link <%= r==7?"active":"" %>" href="<%= ctx %>/reportes.jsp?r=7">5b. Citas por estado (GROUP BY+HAVING)</a></li>
</ul>

<div class="table-responsive">
<table class="table table-striped table-bordered align-middle">
<%
    try {
        con = abrirConexion();
        st = con.createStatement();
        rs = st.executeQuery(sql);
        ResultSetMetaData meta = rs.getMetaData();
        int columnas = meta.getColumnCount();
%>
  <thead class="table-dark">
    <tr>
<%      for (int i = 1; i <= columnas; i++) { %>
      <th><%= esc(meta.getColumnLabel(i)) %></th>
<%      } %>
    </tr>
  </thead>
  <tbody>
<%
        boolean hayFilas = false;
        while (rs.next()) {
            hayFilas = true;
%>
    <tr>
<%          for (int i = 1; i <= columnas; i++) {
                String nombreCol = meta.getColumnLabel(i);
                String valor;
                if ("precio".equals(nombreCol) || "precio_promedio".equals(nombreCol)) {
                    valor = pesos(rs.getDouble(i));
                } else {
                    valor = rs.getString(i);
                }
%>
      <td><%= valor == null ? "" : esc(valor) %></td>
<%          } %>
    </tr>
<%      }
        if (!hayFilas) {
%>
    <tr><td colspan="<%= columnas %>" class="text-center text-muted">Sin resultados.</td></tr>
<%
        }
    } catch (SQLException ex) {
%>
    <tr><td class="text-danger">Error al ejecutar el reporte: <%= esc(ex.getMessage()) %></td></tr>
<%
    } finally {
        cerrar(rs, st, con);
    }
%>
  </tbody>
</table>
</div>

<%@ include file="/WEB-INF/jspf/pie.jspf" %>
