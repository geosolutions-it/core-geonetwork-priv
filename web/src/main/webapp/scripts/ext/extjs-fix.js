/**
 * This fix provide a support for the 'createContextualFragment' in IE9. 
 * IE9 version not support this method.
 */
if ((typeof Range !== "undefined") && !Range.prototype.createContextualFragment){
	Range.prototype.createContextualFragment = function(html){
		var frag = document.createDocumentFragment(),
		div = document.createElement("div");
		frag.appendChild(div);
		div.outerHTML = html;
		return frag;
	};
}	