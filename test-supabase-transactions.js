import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY;

console.log('Supabase URL:', supabaseUrl);
console.log('Supabase Anon Key:', supabaseAnonKey);

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function testTransactionsTable() {
  try {
    const { data, error } = await supabase.from('transactions').select('*');
    if (error) {
      console.error('Error fetching transactions:', error);
    } else {
      console.log('Transactions data:', data);
    }
  } catch (err) {
    console.error('Error connecting to Supabase:', err);
  }
}

testTransactionsTable();
