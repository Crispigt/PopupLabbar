public class Suffix implements Comparable<Suffix> {
    private int index;
    private int rank1;
    private int rank2;

    public Suffix(int ind, int rank1, int rank2) {
        this.index = ind;
        this.rank1 = rank1;
        this.rank2 = rank2;
    }

    public int getIndex() {
        return index;
    }

    public int getRank1() {
        return rank1;
    }

    public int getRank2() {
        return rank2;
    }

    public void setRank1(int rank1) {
        this.rank1 = rank1;
    }

    public void setRank2(int rank2) {
        this.rank2 = rank2;
    }

    @Override
    public int compareTo(Suffix other) {
        if (this.rank1 != other.rank1) {
            return Integer.compare(this.rank1, other.rank1);
        } else {
            return Integer.compare(this.rank2, other.rank2);
        }
    }
}