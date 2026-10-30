/* FRUTIMIA — catálogo editable. Configura aquí los datos comerciales reales. */
const CONFIG = {
  whatsapp: "50498834516", // Escribe el número hondureño: 504XXXXXXXX, sin + ni espacios.
  tiktok: "https://www.tiktok.com/@frutimiaa?_r=1&_t=ZS-9Awa3BrYxRU",   // Ejemplo de formato: https://www.tiktok.com/@tuusuario
  address: "Monjara, playa de Cedeño, calle principal, al lado de Pulpería Dulce.",
  hours: "11:00 A.M. - 09:00 P.M.",
  mapUrl: "https://maps.app.goo.gl/iMLzs7KdYMLttHLC6",
};

const CATEGORY_DATA = [
  {id:"licuados",name:"Licuados",image:"images/Catelicuados.png",tone:"#fff0f4",icon:"🥤",count:10,customLabel:"Licuado personalizado"},
  {id:"granitas",name:"Granitas",image:"images/Categranitas.png",tone:"#e3f4fa",icon:"🧋",count:14,customLabel:"Granita personalizada"},
  {id:"helados",name:"Helados",image:"images/Catehela.png",tone:"#fff0bd",icon:"🍦",count:3,customLabel:"Helado personalizado"},
  {id:"granizado-frutas",name:"Granizado de frutas",image:"images/Categranu.png",tone:"#dff4e9",icon:"🍧",count:4,customLabel:"Granizado personalizado"},
  {id:"minutas",name:"Minutas",image:"images/Cateminu.png",tone:"#fbe7db",icon:"🍨",count:5,customLabel:"Minuta personalizada"}
];

// Catálogo de productos sin precios publicados.
const PRODUCT_NAMES = {
  licuados:["Licuado de fresa","Licuado de banano","Licuado de chocolate","Licuado de papaya","Licuado de confle","Licuado de avena","Licuado de granola","Licuado de cereal","Licuado oreo","Licuado de oreo con fresa"],
  granitas:["Granita de fresa","Granita de cafe","Granita de melon","Granita de limon con piña","Granita de mango","Granita de limon con piña","Granita de sandía","Granita de guayaba","Granita de coco","Granita de coco con piña","Granita de fresa con limon","Granita de tutti frutti","Granita de mango con piña","Granita de cafe con oreo"],
  helados:["Fresas con crema","Banana split","Cono"],
  "granizado-frutas":["Granizado de fresa","Granizado de piña","Granizado de mango","Granizado de tutti frutti"],
  minutas:["Minuta de fresa","Minuta de uva","Minuta de tamarindo","Minuta piña","Minuta de mora"]
};
const PRODUCTS = CATEGORY_DATA.flatMap(cat => PRODUCT_NAMES[cat.id].map((name,i)=>({
  id:`${cat.id}-${i+1}`,category:cat.id,name,
  description:"Producto de catálogo editable. Consulta disponibilidad.",
  image:`images/imagen-${String(i+6).padStart(2,"0")}.jpg`,
  provisional:true
})));
const FAVORITES = [
  {productId:"granitas-2",image:"images/granicafe.png"},
  {productId:"granitas-1",image:"images/granifresa.png"},
  {productId:"helados-1",image:"images/fresascrema.png"}
];
const CUSTOM_OPTIONS = {
  licuados:{main:["Fresa","Banano","Mango","Piña","Papaya","Melón","Mora","Chocolate","Tropical"],extra:["Fresa","Banano","Mango","Piña","Papaya","Mora"],toppings:["Chocolate","Leche condensada","Crema batida","Galleta triturada"],note:"Puedes indicar si deseas leche, agua o sin azúcar en las instrucciones."},
  granitas:{main:["Fresa","Uva","Limón","Naranja","Mango","Piña","Sandía","Manzana","Cereza","Mora","Maracuyá","Tropical"],extra:["Fresa","Uva","Limón","Naranja","Mango","Piña","Mora"],toppings:["Gomitas","Perlas dulces","Leche condensada"],note:"Los sabores disponibles deben confirmarse con FRUTIMIA."},
  helados:{main:["Fresa","Vainilla","Chocolate"],extra:["Fresa","Vainilla","Chocolate"],toppings:["Chispas de chocolate","Galleta triturada","Sirope","Leche condensada"],note:"Indica cualquier preferencia adicional en las instrucciones."},
  "granizado-frutas":{main:["Fresa","Mango","Piña","Sandía","Frutas mixtas","Tropical"],extra:["Fresa","Mango","Piña","Sandía","Mora"],toppings:["Leche condensada","Sirope","Fruta adicional"],note:"Los sabores y complementos pueden variar según disponibilidad."},
  minutas:{main:["Fresa","Uva","Limón","Mango","Tropical"],extra:["Fresa","Uva","Limón","Mango"],toppings:["Leche condensada","Sirope","Gomitas"],note:"Los complementos se confirmarán al realizar el pedido."}
};
const FAQS = [
  {keys:["categoria","categoría","menu","menú","que venden","qué venden","productos"],answer:"Tenemos cinco categorías: licuados, granitas, helados, granizado de frutas y minutas. 🍓 Toca una categoría en la página para explorar sus productos."},
  {keys:["precio","cuanto cuesta","cuánto cuesta","cuanto vale","cuánto vale","costo","vale"],answer:"Para conocer los detalles de cada producto, disponibilidad y realizar tu pedido, escríbenos por WhatsApp."},
  {keys:["pedido","pedir","comprar","orden","encargar"],answer:"Agrega productos al carrito y al finalizar puedes elegir entre enviar el pedido por WhatsApp o registrarlo directamente desde FRUTIMIA con tu cuenta."},
  {keys:["personalizar","personalizado","sabor","sabores","topping","complemento"],answer:"En cada categoría hay una tarjeta PERSONALIZA AL GUSTO. Elige el sabor, los extras disponibles, la cantidad y añade instrucciones."},
  {keys:["whatsapp","contacto","contactar","numero","número"],answer:"Puedes usar los botones de WhatsApp. El número debe configurarse en la variable CONFIG.whatsapp dentro de js/script.js."},
  {keys:["horario","abierto","abren","cierran","hora"],answer:"El horario todavía no está configurado. Contacta a FRUTIMIA para confirmar las horas de atención."},
  {keys:["direccion","dirección","ubicacion","ubicación","donde","dónde","llegar"],answer:"La dirección aún está pendiente de configurar. Contacta a FRUTIMIA para recibir la ubicación correcta."},
  {keys:["tiktok","redes","social"],answer:"El enlace de TikTok se configura en CONFIG.tiktok dentro de js/script.js."},
  {keys:["favorito","preferidos","recomendado","recomendados"],answer:"Puedes tocar la franja rosa PRODUCTOS PREFERIDOS DE FRUTIMIA para ver tres productos destacados."},
  {keys:["gracias","muchas gracias"],answer:"¡Con mucho gusto! 🍓 Si necesitas más información o confirmar disponibilidad, puedes contactar a FRUTIMIA por WhatsApp."},
  {keys:["hola","buenas","buenos dias","buenos días","buenas tardes","hey"],answer:"¡Hola! 🍓 Bienvenido/a a FRUTIMIA. ¿Quieres conocer las categorías o saber cómo hacer un pedido?"}
];
// Variaciones de preguntas frecuentes (más de 170 frases reconocidas por coincidencia).
const FAQ_VARIATIONS = [
  "qué productos tienen","que productos venden","qué opciones hay","quiero ver el menú","muéstrame el catálogo","ver categorías","tienen licuados","venden licuados","quiero una granita","tienen granitas","venden helados","hay helados","quiero un granizado","tienen minutas","qué sabores hay","sabores disponibles","puedo combinar sabores","se puede personalizar","quiero personalizar mi bebida","cómo personalizo mi pedido","puedo agregar toppings","qué toppings tienen","hay complementos","puedo elegir la cantidad","quiero dos unidades","cómo cambio la cantidad","puedo poner instrucciones","puedo pedir sin azúcar","puedo pedir por whatsapp","cómo les escribo","quiero hacer una orden","quiero encargar algo","cómo funciona el pedido","el pedido se envía solo","debo confirmar el pedido","cuál es el número de whatsapp","dónde está el whatsapp","cuánto vale un licuado","precio de las granitas","precio de helados","cuánto cuestan las minutas","tienen lista de precios","hay promociones","qué ofertas tienen","hay descuentos","cuál es su horario","a qué hora abren","a qué hora cierran","abren hoy","están atendiendo","cuál es la dirección","cómo llego al local","dónde queda frutimia","tienen tiktok","cuál es su usuario de tiktok","cuáles son sus favoritos","qué producto recomiendan","qué tiene el licuado","qué contiene la granita","hay fruta fresca","qué sabores de helado tienen","tienen chocolate","tienen fresa","tienen mango","tienen vainilla","tienen piña","tienen banano","tienen mora","tienen uva","tienen limón","tienen naranja","tienen sandía","tienen maracuyá","se puede mezclar fresa y banano","puedo elegir varios sabores","qué incluye el producto","puedo pedir sin topping","puedo quitar un ingrediente","puedo agregar leche condensada","hay sirope","hay gomitas","hay galleta","puedo pedir para llevar","puedo pedir varias bebidas","puedo pedir más de una unidad","se calcula el subtotal","el precio está confirmado","por qué dice precio por confirmar","cómo actualizo los precios","cómo agrego una foto","cómo cambio el logo","cómo se usa la web","funciona en el celular","puedo volver atrás","cómo regreso al inicio","cómo veo otras categorías","el chat responde precios","tienen atención al cliente","cómo consulto disponibilidad","hay producto disponible","qué hago si no aparece una foto","puedo abrir whatsapp después","se guardan mis opciones","puedo editar mi pedido","cómo cierro el chat","quiero hablar con alguien","quiero información","necesito ayuda","me puedes ayudar","buen día","buenas noches","hola frutimia","saludos","perfecto gracias","ok gracias","entendido","genial","hasta luego","adiós","qué venden hoy","qué me recomiendan","quiero algo frío","algo refrescante","quiero una bebida de fruta","quiero un postre","hay productos nuevos","cuál es el producto más vendido","puedo ver fotos","las fotos son reales","dónde cambio las imágenes","cómo pongo mi número","cómo agrego el tiktok","puedo modificar la dirección","dónde cambio el horario","cómo edito las categorías","cuántos productos hay","cuántas categorías hay","qué incluye la personalización","puedo escribir una nota","hay precio por cantidad","puedo pedir sin azúcar adicional","puedo agregar fruta extra","se puede pedir con chocolate","puedo pedirlo para otra persona","cómo confirmar el costo","quién atiende whatsapp","cómo se envía el mensaje","el sitio cobra en lempiras","qué significa precio pendiente","dónde encuentro el catálogo","puedo usar la página en computadora","puedo usarla en android","el menú funciona sin internet","necesito instalar algo","cómo abrir el proyecto","qué archivos debo editar","dónde está el archivo javascript","dónde está la hoja de estilos","cómo cambiar colores","cómo cambio el nombre del producto","cómo elimino un producto","cómo pongo un precio","cómo agrego un favorito","cómo cambio los favoritos","qué es un producto provisional","por qué el precio no aparece","hay que confirmar sabores","qué hago si whatsapp no abre","puedo cancelar el pedido","puedo cambiar mi selección","cómo vuelvo al producto","cómo contactar a frutimia","puedo consultar por tiktok","el chatbot es una persona","el chatbot usa inteligencia artificial","las existencias están actualizadas","dónde verifico disponibilidad","quiero saber más","información de productos","me interesa una granita","me interesa un helado","me interesa una minuta","quiero un licuado especial","quiero un granizado tropical","hay opciones personalizadas","puedo seleccionar toppings","puedo añadir varios complementos","quiero consultar una promoción","cómo hago una consulta","cómo pedir un producto normal","dónde están los productos preferidos","qué hace el botón inicio","qué hace el botón atrás","puedo volver con el gesto del teléfono","por qué no hay precios","cómo sé el precio final","puedo confirmar el total por whatsapp","quiero ver contacto","cómo se usa el asistente","qué puedo preguntar aquí","dime las categorías","dime cómo pedir","quiero ayuda con un pedido","puedo comprar desde el teléfono","se adapta a la pantalla","cómo abrir la web en visual studio code"
];
function normalize(str){return String(str||"").toLocaleLowerCase("es").normalize("NFD").replace(/[\u0300-\u036f]/g,"").trim()}
const $ = id => document.getElementById(id);
const state = {view:"home",category:null,modal:null,formData:null,previousView:"home",scrollY:0};
function categoryById(id){return CATEGORY_DATA.find(c=>c.id===id)}
function productById(id){return PRODUCTS.find(p=>p.id===id)}
function openWhatsApp(message){
  if(!CONFIG.whatsapp || !/^504\d{8}$/.test(CONFIG.whatsapp)){
    alert("El número de WhatsApp aún no está configurado. Edita CONFIG.whatsapp en js/script.js con 504 seguido de los 8 dígitos del número.");
    return;
  }
  const url=`https://wa.me/${CONFIG.whatsapp}?text=${encodeURIComponent(message)}`;
  window.open(url,"_blank","noopener,noreferrer");
}
function productMessage(p,qty=1){
  return `Hola, quiero realizar un pedido en FRUTIMIA.\n\nCategoría: ${categoryById(p.category).name}\nProducto: ${p.name}\nCantidad: ${qty}\n\nPor favor, confirmen disponibilidad y detalles del pedido.\n\nGracias.`;
}
function safeImage(src,alt,kind="fruit"){
  return `<img src="${src}" alt="${alt}" loading="lazy" onerror="this.onerror=null;this.replaceWith(Object.assign(document.createElement('div'),{className:'image-placeholder',innerHTML:'<div>${kind==="logo"?"🍓":"🍓"}<small>Agrega tu imagen</small></div>'}))">`;
}
function renderCategories(){
  $("categoryGrid").innerHTML=CATEGORY_DATA.map((c,i)=>`<button class="category-card fade-up" style="animation-delay:${i*70}ms" data-category="${c.id}" aria-label="Ver ${c.name}"><span class="category-image">${safeImage(c.image,c.name,c.id)}</span><span class="category-meta"><strong>${c.name}</strong><span>↗</span></span></button>`).join("");
}
function productCard(p){
  return `<article class="product-card"><button class="product-image product-image-button" data-order="${p.id}" aria-label="Toca la foto para pedir ${p.name}">${safeImage(p.image,p.name,p.category)}<span class="image-action-hint">Toca la foto para pedir <b>↗</b></span></button><div class="product-info"><h3>${p.name}</h3><p>${p.description}</p><div class="product-actions"><button class="small-btn primary" data-order="${p.id}">🟢 Agregar al pedido</button></div></div></article>`;
}
function customCard(cat){return `<article class="product-card custom-card"><div class="custom-emoji">${cat.icon}</div><span class="eyebrow">HECHO A TU MANERA</span><h3>Personaliza al gusto</h3><p>Combina sabores y complementos para crear una opción a tu estilo. Consulta los detalles y la disponibilidad directamente con FRUTIMIA.</p><button class="small-btn primary" data-custom="${cat.id}">Crear mi producto ↗</button></article>`}
function renderCatalog(catId){
  const cat=categoryById(catId);if(!cat)return;
  state.category=catId;$("catalogTitle").textContent=cat.name;$("catalogEyebrow").textContent=`${PRODUCTS.filter(p=>p.category===catId).length} OPCIONES PARA DISFRUTAR`;
  $("productGrid").innerHTML=PRODUCTS.filter(p=>p.category===catId).map(productCard).join("")+customCard(cat);
}
function renderFavorites(){
  $("favoritesGrid").innerHTML=FAVORITES.map(f=>{
    const p=productById(f.productId);if(!p)return "";
    return `<article class="product-card"><button class="product-image product-image-button" data-order="${p.id}" aria-label="Toca la foto para pedir ${p.name}">${safeImage(p.image,p.name,"favorito")}<span class="image-action-hint">Toca la foto para pedir <b>↗</b></span></button><div class="product-info"><span class="eyebrow">♡ PREFERIDO FRUTIMIA</span><h3>${p.name}</h3><p>${p.description}</p><button class="small-btn primary" data-order="${p.id}">🟢 Agregar al pedido</button></div></article>`;
  }).join("");
}
function renderFavoriteTeasers(){
  $("favoriteTeasers").innerHTML=FAVORITES.map(f=>{const p=productById(f.productId);if(!p)return "";return `<button class="favorite-teaser" data-order="${p.id}" aria-label="Toca para pedir ${p.name}">${safeImage(p.image,p.name,"favorito")}<span>${p.name}</span><b>Ver y pedir ↗</b></button>`}).join("");
}
function showView(view,category=null,addHistory=true){
  state.scrollY=window.scrollY;state.view=view;state.category=category;
  $("categoriesSection").classList.toggle("hidden",view!=="home");
  $("catalogSection").classList.toggle("hidden",view!=="catalog");
  $("favoritesSection").classList.toggle("hidden",view!=="favorites");
  if(view==="catalog")renderCatalog(category);
  if(view==="favorites")renderFavorites();
  if(view==="home"){$("hero").classList.remove("hidden");}
  else {$("hero").classList.remove("hidden");}
  if(addHistory){history.pushState({frutimia:true,view,category}, "", `#${view}${category?`-${category}`:""}`)}
  if(view==="home"){window.scrollTo({top:0,behavior:reducedMotion()?"auto":"smooth"});}
  else {const target=view==="catalog"?$("catalogSection"):view==="favorites"?$("favoritesSection"):$("contactSection");setTimeout(()=>target.scrollIntoView({behavior:reducedMotion()?"auto":"smooth",block:"start"}),0);}
}
function reducedMotion(){return window.matchMedia&&window.matchMedia("(prefers-reduced-motion: reduce)").matches}
function openModal(html,modalName){
  state.previousView=state.view;state.modal=modalName;$("modalBody").innerHTML=html;$("modalBackdrop").classList.remove("hidden");document.body.style.overflow="hidden";
  history.pushState({frutimia:true,view:state.view,category:state.category,modal:modalName},"",`#${state.view}${state.category?`-${state.category}`:""}-${modalName}`);
}
function closeModal(fromPop=false){
  if($("modalBackdrop").classList.contains("hidden"))return;
  $("modalBackdrop").classList.add("hidden");$("modalBody").innerHTML="";document.body.style.overflow="";state.modal=null;
  if(!fromPop && history.state && history.state.modal) history.back();
}
function orderQuantity(p){
  openModal(`<h2 id="modalTitle">Pedir ${p.name}</h2><p class="modal-intro">Indica cuántas unidades deseas.</p><form id="quantityForm"><div class="field"><label for="normalQty">Cantidad</label><input id="normalQty" type="number" min="1" max="99" value="1" required></div><button class="primary-btn" type="submit">Continuar por WhatsApp ↗</button></form>`,"quantity");
  $("quantityForm").addEventListener("submit",e=>{e.preventDefault();const q=Math.max(1,Math.min(99,Number($("normalQty").value)||1));closeModal();openWhatsApp(productMessage(p,q))});
}
function customModal(categoryId){
  const cat=categoryById(categoryId),opts=CUSTOM_OPTIONS[categoryId];
  const optionList=(items,name)=>items.map((x,i)=>`<label class="check-option"><input type="checkbox" name="${name}" value="${x}"> ${x}</label>`).join("");
  openModal(`<h2 id="modalTitle">Personaliza al gusto</h2><p class="modal-intro">${cat.name}: crea tu combinación. ${opts.note}</p>
  <form id="customForm"><div class="field"><label for="mainFlavor">Sabor principal *</label><select id="mainFlavor" required><option value="">Selecciona un sabor</option>${opts.main.map(x=>`<option>${x}</option>`).join("")}</select></div>
  <div class="field"><label>Sabores adicionales</label><div class="check-list">${optionList(opts.extra,"extraFlavor")}</div></div>
  <div class="field"><label>Toppings y complementos</label><div class="check-list">${optionList(opts.toppings,"topping")}</div></div>
  <div class="field"><label for="customQty">Cantidad *</label><input id="customQty" type="number" min="1" max="99" value="1" required></div>
  <div class="field"><label for="customNotes">Instrucciones especiales</label><textarea id="customNotes" maxlength="500" placeholder="Ej.: sin azúcar adicional..."></textarea></div>
  <p class="modal-error hidden" id="customError">Elige un sabor principal y una cantidad válida.</p>
  <button class="primary-btn" type="submit">Enviar pedido por WhatsApp ↗</button></form>`,"custom");
  $("customForm").addEventListener("submit",e=>{
    e.preventDefault();const main=$("mainFlavor").value,qty=Number($("customQty").value);
    if(!main||!Number.isInteger(qty)||qty<1||qty>99){$("customError").classList.remove("hidden");return}
    const extras=[...document.querySelectorAll('input[name="extraFlavor"]:checked')].map(x=>x.value);
    const toppings=[...document.querySelectorAll('input[name="topping"]:checked')].map(x=>x.value);
    const notes=$("customNotes").value.trim();
    const message=`Hola, quiero realizar un pedido en FRUTIMIA.\n\nCategoría: ${cat.name}\nProducto: ${cat.customLabel}\nSabor principal: ${main}\nSabores adicionales: ${extras.length?extras.join(", "):"Ninguno"}\nToppings y complementos: ${toppings.length?toppings.join(", "):"Ninguno"}\nCantidad: ${qty}\nInstrucciones especiales: ${notes||"Ninguna"}\n\nGracias.`;
    state.formData={categoryId,main,extras,toppings,qty,notes};closeModal();openWhatsApp(message);
  });
}
function handleClick(e){
  const nav=e.target.closest("[data-nav]");if(nav){const v=nav.dataset.nav;if(v==="categories"){showView("home");$("categoriesSection").scrollIntoView({behavior:reducedMotion()?"auto":"smooth"})}else if(v==="contact")$("contactSection").scrollIntoView({behavior:reducedMotion()?"auto":"smooth"});else showView("home");return}
  const cat=e.target.closest("[data-category]");if(cat){showView("catalog",cat.dataset.category);return}
  const order=e.target.closest("[data-order]");if(order){const p=productById(order.dataset.order);if(p)orderQuantity(p);return}
  const qty=e.target.closest("[data-qty]");if(qty){const p=productById(qty.dataset.qty);if(p)orderQuantity(p);return}
  const custom=e.target.closest("[data-custom]");if(custom){customModal(custom.dataset.custom);return}
  const chat=e.target.closest("[data-chat]");if(chat){sendChat(chat.dataset.chat);return}
}
document.addEventListener("click",handleClick);
$("backBtn").addEventListener("click",()=>{if(! $("modalBackdrop").classList.contains("hidden")){closeModal();return}if(state.view!=="home"){showView("home");return}if(history.length>1)history.back();else showView("home")});
$("homeBtn").addEventListener("click",()=>{if(!$("modalBackdrop").classList.contains("hidden"))closeModal();showView("home")});
$("brandHome").addEventListener("click",e=>{e.preventDefault();showView("home")});
$("footerHome").addEventListener("click",e=>{e.preventDefault();showView("home")});
$("catalogBack").addEventListener("click",()=>showView("home"));

$("modalClose").addEventListener("click",()=>closeModal());
$("modalBackdrop").addEventListener("click",e=>{if(e.target===$("modalBackdrop"))closeModal()});
document.addEventListener("keydown",e=>{if(e.key==="Escape"){closeModal();$("chatPanel").classList.add("hidden")}});
window.addEventListener("popstate",e=>{
  if(!$("modalBackdrop").classList.contains("hidden")){closeModal(true);return}
  const s=e.state;
  if(s&&s.frutimia){state.view=s.view||"home";state.category=s.category||null;showView(state.view,state.category,false)}
  else showView("home",null,false);
});
function configureContact(){
  $("addressText").textContent=CONFIG.address;$("hoursText").textContent=CONFIG.hours;
  const maps=$("contactMaps");if(maps)maps.href=CONFIG.mapUrl||"https://www.google.com/maps/search/?api=1&query=FRUTIMIA";
  const wa=CONFIG.whatsapp&&/^504\d{8}$/.test(CONFIG.whatsapp)?`https://wa.me/${CONFIG.whatsapp}`:"#";
  $("contactWhatsApp").href=wa;$("contactWhatsApp").addEventListener("click",e=>{if(wa==="#"){e.preventDefault();openWhatsApp("Hola, quisiera información sobre FRUTIMIA.")}});
  if(CONFIG.tiktok){$("contactTikTok").href=CONFIG.tiktok}else{$("contactTikTok").href="#";$("contactTikTok").addEventListener("click",e=>{e.preventDefault();alert("Configura el enlace de TikTok en CONFIG.tiktok dentro de js/script.js.")})}
}
function sendChat(raw){
  const text=String(raw||"").trim();if(!text)return;
  addChatMessage(text,"user");$("chatInput").value="";
  const n=normalize(text);let answer=null;
  for(const f of FAQS){if(f.keys.some(k=>n.includes(normalize(k)))){answer=f.answer;break}}
  if(!answer){const match=FAQ_VARIATIONS.find(q=>n.includes(normalize(q))||normalize(q).includes(n)&&n.length>5);if(match){
    if(/precio|cuesta|vale|costo|promocion|oferta|descuento/.test(n))answer="Para recibir información sobre los productos, escríbenos directamente por WhatsApp.";
    else if(/horario|abren|cierran|direccion|ubicacion|donde queda/.test(n))answer="El horario y la dirección están pendientes de configurar. Contacta a FRUTIMIA por WhatsApp para confirmar los datos.";
    else answer="Puedes explorar las cinco categorías y usar PERSONALIZA AL GUSTO para preparar tu pedido. Si necesitas confirmar detalles, contacta a FRUTIMIA por WhatsApp.";
  }}
  if(!answer)answer="¡Gracias por escribir! No tengo ese dato configurado todavía. Puedes consultar directamente a FRUTIMIA por WhatsApp para confirmar horarios, ubicación y disponibilidad.";
  setTimeout(()=>addChatMessage(answer,"bot"),180);
}
function addChatMessage(text,type){const d=document.createElement("div");d.className=type==="user"?"user-message":"bot-message";d.textContent=text;$("chatMessages").appendChild(d);$("chatMessages").scrollTop=$("chatMessages").scrollHeight}
$("chatLauncher").addEventListener("click",()=>{$("chatPanel").classList.toggle("hidden");if(!$("chatPanel").classList.contains("hidden"))$("chatInput").focus()});
$("chatClose").addEventListener("click",()=>$("chatPanel").classList.add("hidden"));
$("chatForm").addEventListener("submit",e=>{e.preventDefault();sendChat($("chatInput").value)});
function setupImageFallbacks(){
  document.querySelectorAll("img[data-fallback]").forEach(img=>img.addEventListener("error",function(){if(this.dataset.failed)return;this.dataset.failed="1";this.style.display="none";const span=document.createElement("span");span.className="logo-fallback";span.textContent=this.dataset.fallback==="chat"?"🍓":"🍓";this.parentNode.insertBefore(span,this.nextSibling)}));
}
// Hero fade uses a local image; still works without GSAP.
function setupHeroFade(){
  const hero=$("hero"),photo=hero.querySelector(".hero-photo");
  const update=()=>{if(reducedMotion()){photo.style.opacity="1";return}const rect=hero.getBoundingClientRect();const progress=Math.max(0,Math.min(1,(0-rect.top)/(rect.height*.72)));photo.style.opacity=String(1-progress*.92)};
  window.addEventListener("scroll",update,{passive:true});window.addEventListener("resize",update);update();
}
function init(){
  renderCategories();renderFavorites();renderFavoriteTeasers();configureContact();setupImageFallbacks();setupHeroFade();$("year").textContent=new Date().getFullYear();
  const hash=location.hash.replace("#","");const cat=CATEGORY_DATA.find(c=>hash.endsWith(c.id));
  if(hash.startsWith("catalog")&&cat)showView("catalog",cat.id,false);
}
init();
