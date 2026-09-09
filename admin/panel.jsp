<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% String tituloPagina = "Administración"; %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
  <h1>Panel de administración</h1>
  <p>Aquí vas a gestionar usuarios y roles, activar/inactivar cuentas,
     parametrizar catálogos (ciudades, tipos de propiedad, características)
     y consultar la auditoría.</p>
  <p><small>Contenido real se agrega más adelante junto con los reportes
     (paso 12).</small></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>