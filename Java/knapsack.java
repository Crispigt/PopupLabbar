/**
 * Knapsack problem where you aim to select items to put in the knapsack such that is retains
 * 	 the highest possible value without exceeding the capacity
 * 
 *  We solve this using dynamic programming
 *  Time Complexity O(nC) => O(number of items * Capacity)
 * 
 *
 * @author Viktor Widin
 */
package Java;
import java.math.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Scanner;

public class knapsack {
	/**
	 * 
	 * Cap - max capacity of knapsack
	 * Cases - number of items
	 * w - weights of items
	 * v - values of items
	 */
	public static void main(String[] args) {
		
		Kattio io = new Kattio(System.in, System.out);

		while(io.hasMoreTokens()){
			
			int cap = io.getInt();
			int cases = io.getInt();
			int[] w = new int[cases];
			int[] val = new int[cases];
			
			for(int i = 0; i < cases; i++){
				val[i] = io.getInt();
				w[i] = io.getInt();
			}
			knapsackSolve(cap, w, val);
		}
		io.close();
	}
	
	/**
	 * 
	 * @param capacity max capacity of knapsack
	 * @param Weight array of weights
	 * @param Value array of values
	 * @return the maximum possible value of items that fit in the knapsack
	 */
	
	public static int knapsackSolve(int capacity, int[] Weight, int[] Value) {
		
		//An array that initializes to 0 where each row is an item and each column is the
		//weight of the knapsack, increasing from 0 to capacity.
		int[][] Matrix = new int[Weight.length + 1][capacity +1];
		
		int numItems = Weight.length;
		
		for(int i = 1; i < numItems+1; i++){
			
			int weightItem = Weight[i-1];
			int valueItem = Value[i-1];
						
			
			for(int j = 1; j < capacity+1; j++){
				
				//If the weight of the item is bigger than the weight currently represented in the
				//matrix, then just chose the value above it -- the largest value we have previously
				//found for that weight
				if(weightItem > j){
					Matrix[i][j] = Matrix[i-1][j];
				} else {
					
					// Check if the previously found value for this weight (j) is bigger than 
					//the value of this item + the value that can be added with the excess weight
					int tempMax = Math.max(Matrix[i-1][j], Matrix[i-1][j-weightItem] + valueItem);
					Matrix[i][j] = tempMax;
					
				}
				
			}
		}
		
		int tempCapacity = capacity;
		List<Integer> list  =new ArrayList<Integer>();
		
		//Go through the items in Matrix, starting from Matrix[last][last] to see if the value above it 
		//is the same, if it is not, then this item has been selected.
		for(int i = numItems; i> 0; i--){
			if(Matrix[i][tempCapacity] != Matrix[i-1][tempCapacity]){
	
				list.add(i-1);
				
				//Once we find an item that was selected, we then reduce the temporary capacity
				// to find the remaining items, until all have been found. 
				tempCapacity = tempCapacity - Weight[i-1];
				
			}
		}
		

		System.out.println(list.size());
	    String text = Arrays.toString(list.toArray());
	    text = text.replace("]", "").replace("[", "").replace(",", "");
	    System.out.println(text);
	    
	    //Returns max value, but we don't need it for the lab. Might be useful generically
		return Matrix[numItems][capacity];
		
	}
}
