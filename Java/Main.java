package Java;
import java.io.FileInputStream;
import java.io.IOException;


public class Main {

    public static void main(String[] args) {
        Kattio io = new Kattio(System.in, System.out);

        int N = io.getInt();

        //a0, ..., aN
        long[] a = new long[N + 1];
        for (int i = 0; i <= N; i++) {
            a[i] = io.getLong();
        }

        // x0, ..., xN-1
        long[] initialX = new long[N];
        if (N > 0) { // Read only if N > 0
            for (int i = 0; i < N; i++) {
                initialX[i] = io.getLong();
            }
        }

        LinearRecurrenceSolver solver = new LinearRecurrenceSolver(N, a, initialX);

        int Q = io.getInt(); 
        while (Q-- > 0) {
            long T = io.getLong(); 
            long M = io.getLong(); 

            long result = solver.solve(T, M);

            io.println(result);
        }

        io.close();
    }
}