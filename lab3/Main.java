import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.StringTokenizer;

public class Main {
    public static void main(String[] args) throws IOException {
        FastIO io = new FastIO();
        StringBuilder output = new StringBuilder();

        String line;
        while ((line = io.nextLine()) != null && !line.isEmpty()) {
            SuffixArray sa = new SuffixArray(line);
            String queryLine = io.nextLine();
            if (queryLine == null) break;
            StringTokenizer st = new StringTokenizer(queryLine);
            int n = Integer.parseInt(st.nextToken());
            for (int i = 0; i < n; i++) {
                int q = Integer.parseInt(st.nextToken());
                output.append(sa.getSuffix(q)).append(" ");
            }
            output.append('\n');
        }

        io.print(output.toString());
        io.close();
    }

    static class FastIO {
        private BufferedReader br;
        private PrintWriter pw;

        public FastIO() {
            br = new BufferedReader(new InputStreamReader(System.in));
            pw = new PrintWriter(System.out);
        }

        public String nextLine() throws IOException {
            String line = br.readLine();
            return line != null ? line.trim() : null;
        }

        public void print(String s) {
            pw.print(s);
        }

        public void close() throws IOException {
            pw.flush();
            pw.close();
            br.close();
        }
    }
}