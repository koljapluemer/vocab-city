shader_type canvas_item;

varying flat vec2 vertexPos[2];
uniform vec2 globalMousePos;

void vertex() {
	vertexPos[0] = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// Place fragment code here.
	float isWithinY = step(vertexPos[0].y, globalMousePos.y) * step(globalMousePos.y, vertexPos[0].y + 64.);
	float isWithinX = step(vertexPos[0].x, globalMousePos.x) * step(globalMousePos.x, vertexPos[0].x + 64.);
	float isWithin = isWithinY * isWithinX;
	
	vec4 textureColor = texture(TEXTURE, UV);
	COLOR = mix(textureColor, vec4(0.7,0.,0.,1.0), 0.7* isWithin) ;
}