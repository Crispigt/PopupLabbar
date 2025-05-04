import java.util.Arrays;

public class SuffixArray {
    private int[] suffixArr;

    public SuffixArray(String word) {
        int n = word.length();
        Suffix[] suffixes = new Suffix[n];

        for (int i = 0; i < n; i++) {
            suffixes[i] = new Suffix(i, word.charAt(i), (i + 1 < n) ? word.charAt(i + 1) : -1);
        }

        Arrays.sort(suffixes);

        int[] ranks = new int[n];
        updateRanks(suffixes, ranks);

        for (int k = 4; k < n; k *= 2) {
            for (int i = 0; i < n; i++) {
                suffixes[i].setRank1(ranks[suffixes[i].getIndex()]);
                int nextIndex = suffixes[i].getIndex() + k / 2;
                suffixes[i].setRank2(nextIndex < n ? ranks[nextIndex] : -1);
            }

            Arrays.sort(suffixes);

            if (!updateRanks(suffixes, ranks)) {
                break;
            }
        }

        suffixArr = new int[n];
        for (int i = 0; i < n; i++) {
            suffixArr[i] = suffixes[i].getIndex();
        }
    }

    private boolean updateRanks(Suffix[] suffixes, int[] ranks) {
        int rank = 0;
        int prevRank1 = suffixes[0].getRank1();
        int prevRank2 = suffixes[0].getRank2();
        ranks[suffixes[0].getIndex()] = rank;

        for (int i = 1; i < suffixes.length; i++) {
            int currentRank1 = suffixes[i].getRank1();
            int currentRank2 = suffixes[i].getRank2();
            if (currentRank1 != prevRank1 || currentRank2 != prevRank2) {
                rank++;
                prevRank1 = currentRank1;
                prevRank2 = currentRank2;
            }
            ranks[suffixes[i].getIndex()] = rank;
        }

        return rank < suffixes.length - 1;
    }

    public int getSuffix(int i) {
        return suffixArr[i];
    }
}