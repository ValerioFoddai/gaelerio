import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function testSupabaseConnection() {
  try {
    const { data, error } = await supabase.from('profiles').select('*');
    if (error) {
      console.error('Error fetching data:', error);
    } else {
      console.log('Data fetched successfully:', data);
    }
  } catch (err) {
    console.error('Error connecting to Supabase:', err);
  }
}

testSupabaseConnection();
