<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/jspf/conexion.jspf" %>
<%@ include file="/WEB-INF/jspf/utilidades.jspf" %>
<% String[] rolesPermitidos = {"INMOBILIARIA", "ADMINISTRADOR"}; %>
<%@ include file="/WEB-INF/jspf/seguridad.jspf" %>
<% String tituloPagina = "Mis propiedades"; %>
<%@ include file="/WEB-INF/jspf/cabecera.jspf" %>
  <h1>Panel de la inmobiliaria</h1>
  <p>Aquí vas a publicar y editar tus propiedades, administrar la galería
     de imágenes, atender citas y aprobar o rechazar solicitudes.</p>
  <p><small>Contenido real se agrega en el paso 8 (CRUD de propiedades)
     y el paso 10 (citas y solicitudes).</small></p>
<%@ include file="/WEB-INF/jspf/pie.jspf" %>