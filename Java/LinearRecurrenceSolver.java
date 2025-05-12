package Java;
// Author: Felix Stenberg, Viktor Widin
/**
*
*   Solves a linear homogeneous recurrence relation with constant coefficients.
*   Given a recurrence relation of the form:
*    X(n) = a_1 * X(n-1) + a_2 * X(n-2) + ... + a_N * X(n-N) + a_0
*    with initial values X(0), X(1), ..., X(N-1), this class can compute X(T) modulo M.
*/
public class LinearRecurrenceSolver {

    private final int N;          
    private final long[] a;       
    private final long[] Xi; 

    /**
     * Constructs a LinearRecurrenceSolver.
     * @param n The order of the recurrence relation (N).
     * @param coefficients An array of coefficients [a_1, a_2, ..., a_N, a_0].
     * @param initialValues An array of initial values [X(0), X(1), ..., X(N-1)].
    */
    public LinearRecurrenceSolver(int n, long[] coefficients, long[] initialValues) {
        this.N = n;
        this.a = coefficients;
        this.Xi = initialValues;
    }

    /**
     * Solves the linear recurrence relation to find the T-th term modulo M.
     * 
     * This method uses the matrix exponentiation method to efficiently compute X(T) mod M.
     * 
     * @param T The index of the term to compute (T >= 0).
     * @param M The modulus.
     * @return The value of X(T) modulo M.
     * 
     */
    public long solve(long T, long M) {
        if (M == 1) {
            return 0;
        }


        if (T < N) {
            if (N == 0) {
                 
                return mod(a[0], M);
            } else {
                
                return mod(Xi[(int) T], M);
            }
        }

        Mat AM = new Mat(N); 

        for (int j = 0; j < N; j++) {
            AM.mat[0][j] = mod(a[j + 1], M);
        }
        AM.mat[0][N] = mod(a[0], M);

        for (int i = 1; i < N; i++) { // Loop only up to N-1
            AM.mat[i][i - 1] = 1;
       }

        if (N >= 0) {
            AM.mat[N][N] = 1; 
        }

        long[] S = new long[N + 1];
         if (N > 0) { 
            for (int i = 0; i < N; i++) {
                S[i] = mod(Xi[N - 1 - i], M);
            }
         }
        S[N] = 1; 


        long k = T - (long)N + 1L; 

        Mat A_pow_k = Mat.power(AM, k, M);

        long final_val = 0;
        for (int j = 0; j <= N; j++) { 
            
            long term = multiplyMod(A_pow_k.mat[0][j], S[j], M);
            final_val = (final_val + term);
            if (final_val >= M) final_val -= M; 
        }

        return final_val; 
    }
    /**
    * Multiplies two long integers modulo m using the binary exponentiation (repeated squaring) method
    * to prevent overflow.
    * @param a The first operand.
    * @param b The second operand.
    * @param m The modulus.
    * @return (a * b) % m.
    */
    private static long multiplyMod(long a, long b, long m) {
        a = mod(a, m);
        b = mod(b, m);
        long res = 0;
        while (b > 0) {
            if ((b & 1) == 1) {
                res = (res + a);
                if (res >= m) res -= m;
            }
            a = (a << 1);
            if (a >= m) a -= m;
            b >>= 1;
        }
        return res;
    }
    /**
    * Computes the modulo operation, handling negative inputs correctly.
    * @param a The number.
    * @param m The modulus.
    * @return a % m, always non-negative.
    */
    private static long mod(long a, long m) {
        long res = a % m;
        return (res < 0) ? res + m : res;
    }
    /**
    * Represents a square matrix for matrix exponentiation.
    */
    private static class Mat {
        long[][] mat;
        int size; 
        
        /**
        * Constructs a square matrix of size (N+1) x (N+1).
        * @param N The order of the recurrence relation.
        */
        Mat(int N) {
            this.size = N + 1;
            mat = new long[size][size];
        }

        /**
        * Creates an identity matrix of size (N_degree + 1) x (N_degree + 1).
        * @param N_degree The order of the recurrence relation.
        * @return The identity matrix.
        */
        static Mat identity(int N_degree) {
            Mat I = new Mat(N_degree);
            for (int i = 0; i < I.size; i++) {
                I.mat[i][i] = 1;
            }
            return I;
        }
        /**
        * Multiplies two matrices AM and B modulo M.
        * @param AM The first matrix.
        * @param B The second matrix.
        * @param M The modulus.
        * @return The product matrix (AM * B) % M.
        */
        static Mat multiply(Mat AM, Mat B, long M) {
            int size = AM.size;
            Mat C = new Mat(size - 1); 

            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    long sum = 0;
                    for (int k = 0; k < size; k++) {
                        long product = (long)AM.mat[i][k] * B.mat[k][j];
                        long term = mod(product, M);
                        sum = (sum + term);
                        if (sum >= M) sum -= M; 
                    }
                    C.mat[i][j] = sum; 
                }
            }
            return C;
        }

        /**
        * Computes the matrix AM raised to the power p modulo M using binary exponentiation.
        * @param AM The base matrix.
        * @param p The exponent.
        * @param M The modulus.
        * @return The matrix (AM ^ p) % M.
        */
        static Mat power(Mat AM, long p, long M) {
            Mat res = Mat.identity(AM.size - 1);
            Mat base = new Mat(AM.size - 1);

            for(int i = 0; i < AM.size; i++) {
                 System.arraycopy(AM.mat[i], 0, base.mat[i], 0, AM.size);
            }

            while (p > 0) {
                if ((p & 1) == 1) {
                    res = multiply(res, base, M);
                }
                base = multiply(base, base, M);
                p >>= 1;
            }
            return res;
        }
    } 

}