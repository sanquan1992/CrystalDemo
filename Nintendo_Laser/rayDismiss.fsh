
void main() {
        float PI = 3.1415926;
        float per = u_path_length * (1.0 - u_current_percentage);
        if (v_path_distance > per ) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        }else {
            gl_FragColor = vec4(1.0 - v_path_distance/u_path_length, 1.0, v_path_distance/u_path_length, 1.0);
        }
}
