
void main(){
//    u_time
//    u_texture
//    u_path_length
//    v_tex_coord
//    v_color_mix
//    v_path_distance
/**        Version1.0           **/
    
    float PI = 3.1415926 / 2.0;
    float per = u_path_length * sin( u_time - (PI * floor(u_time/PI)));
    float len = u_path_length / 4.0;
//    if ((v_path_distance > per) && (v_path_distance < per + len)) {
        gl_FragColor = vec4(1.0 - v_path_distance/u_path_length, 1.0, v_path_distance/u_path_length, 1.0);
//    }else {
//        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
//    }

}
