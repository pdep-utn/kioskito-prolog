% Lógica de negocio

% Punto 1
% dodain atiende lunes, miércoles y viernes de 9 a 15.
atiende(dodain, lunes, 9, 15).
atiende(dodain, miercoles, 9, 15).
atiende(dodain, viernes, 9, 15).
% lucas atiende los martes de 10 a 20
atiende(lucas, martes, 10, 20).
% juanC atiende los sábados y domingos de 18 a 22.
atiende(juanC, sabados, 18, 22).
atiende(juanC, domingos, 18, 22).
% juanFdS atiende los jueves de 10 a 20 y los viernes de 12 a 20.
atiende(juanFdS, jueves, 10, 20).
atiende(juanFdS, viernes, 12, 20).
% leoC atiende los lunes y los miércoles de 14 a 18.
atiende(leoC, lunes, 14, 18).
atiende(leoC, miercoles, 14, 18).
% martu atiende los miércoles de 23 a 24.
atiende(martu, miercoles, 23, 24).

% vale atiende los mismos días y horarios que dodain y juanC.
atiende(vale, Dia, Desde, Hasta):-atiende(dodain, Dia, Desde, Hasta).
atiende(vale, Dia, Desde, Hasta):-atiende(juanC, Dia, Desde, Hasta).
% nadie hace el mismo horario que leoC
% por principio de universo cerrado, no debe hacerse nada
% maiu está pensando si hace el horario de 0 a 8 los martes y miércoles
% por principio de universo cerrado, no debe hacerse nada: el dato es desconocido

% Punto 2: quién atiende el kiosko...
% Definir un predicado que permita relacionar un día y hora con una persona, 
% en la que dicha persona atiende el kiosko.
quienAtiende(Persona, Dia, Hora):-
  atiende(Persona, Dia, Desde, Hasta),
  between(Desde, Hasta, Hora).

% Punto 3: Forever alone
% Definir un predicado que permita saber si una persona en un día y horario
% determinado está atendiendo ella sola. En este predicado debe utilizar not/1, 
% y debe ser inversible para relacionar personas.
foreverAlone(Persona, Dia, Hora):-
  persona(Persona),
  not((quienAtiende(OtraPersona, Dia, Hora), Persona \= OtraPersona)).


persona(Persona):-distinct(Persona, atiende(Persona, _, _, _)).

% Punto 4: posibilidades de atención
% Dado un día, queremos relacionar qué personas podrían estar atendiendo el kiosko en algún momento de ese día.
posibilidadesAtencion(Dia, Personas):-
  findall(Persona, atiende(Persona, Dia, _, _), PersonasPosibles),
  combinar(PersonasPosibles, Personas).
% - Findall para saltear al motor y agrupar las personas que atienden ese día
% con el formato de lista

combinar([], []).
combinar([Persona|Posibles], [Persona|Personas]):-
  combinar(Posibles, Personas).
combinar([_|Posibles], Personas):-
  combinar(Posibles, Personas).
% - Recursividad + el mecanismo de backtracking me permiten encontrar
% múltiples soluciones al mismo problema (la combinatoria, que en funcional
% requiere echar mano a modelar estados computacionales, como las mónadas).

% Punto 5
% En el kiosko tenemos por el momento tres ventas posibles:
% - golosinas, en cuyo caso registramos el valor en plata
% - cigarrillos, de los cuales registramos todas las marcas de cigarrillos que se vendieron (ej: Marlboro y Particulares)
% - bebidas, en cuyo caso registramos si son alcohólicas y la cantidad

% dodain hizo las siguientes ventas el lunes 10/08
% lunes 10 de agosto: golosinas por $ 1200, cigarrillos Jockey, golosinas por $ 50
venta(dodain, lunes, 10, 8, [golosinas(1200), cigarrillos([jockey]), golosinas(50)]).
% dodain hizo las siguientes ventas el miércoles 12 de agosto: 8 bebidas alcohólicas, 
% 1 bebida no-alcohólica, golosinas por $ 10
venta(dodain, lunes, 12, 8, [bebidas(true, 8), bebidas(false, 1), golosinas(10)]).
% martu hizo las siguientes ventas el miercoles 12 de agosto: golosinas por $ 1000, cigarrillos Chesterfield, Colorado y Parisiennes.
venta(martu, miercoles, 12, 8, [golosinas(1000), cigarrillos([chesterfield, colorado, parisiennes])]).
% lucas hizo las siguientes ventas el martes 11 de agosto: golosinas por $ 600.
venta(lucas, martes, 11, 8, [golosinas(600)]).
% lucas hizo las siguientes ventas el martes 18 de agosto: 2 bebidas no-alcohólicas y cigarrillos Derby.
venta(lucas, martes, 18, 8, [bebidas(false, 2), cigarrillos([derby])]).

% Queremos saber si una persona vendedora es suertuda, esto ocurre si para todos los días en los que vendió, 
% la primera venta que hizo fue importante. Una venta es importante:
% - en el caso de las golosinas, si supera los $ 100.
% - en el caso de los cigarrillos, si tiene más de dos marcas.
% - en el caso de las bebidas, si son alcohólicas o son más de 5.
personaSuertuda(Persona):-personaQueVende(Persona), 
  forall(venta(Persona, _, _, _, [Venta|_]), importante(Venta)).

personaQueVende(Persona):-distinct(Persona, venta(Persona, _, _, _, _)).

importante(golosinas(Plata)):-Plata > 100.
importante(cigarrillo(Marcas)):-length(Marcas, Cantidad), Cantidad > 2.
importante(bebidas(true, _)).
importante(bebidas(false, Cantidad)):-Cantidad > 5.

% =====================================================================================
% Tests
% Punto 1

:- begin_tests(kioskito).

test(atienden_los_viernes, set(Persona == [dodain, vale, juanFdS])):-
    atiende(Persona, viernes, _, _).

test(personas_que_atienden_los_lunes_a_las_14, set(Persona == [dodain, leoC, vale])):-
  quienAtiende(Persona, lunes, 14).

test(que_momentos_atiende_una_persona, set(Dia == [lunes, miercoles, viernes])):-
  quienAtiende(vale, Dia, 10).

test(personas_forever_alone, set(Persona = [lucas])):-
  foreverAlone(Persona, martes, 19).

test(combinatoria_atencion_un_dia, set(Persona = [
    [],[dodain],[dodain,leoC],[dodain,leoC,martu],[dodain,leoC,martu,vale],
    [dodain,leoC,vale],[dodain,martu],[dodain,martu,vale],[dodain,vale],
    [leoC],[leoC,martu],[leoC,martu,vale],[leoC,vale],[martu],[martu,vale],[vale]
  ])):-
  posibilidadesAtencion(miercoles, Persona).

test(personas_suertudas, set(Persona = [martu, dodain])):-
  personaSuertuda(Persona).

:-end_tests(kioskito).

