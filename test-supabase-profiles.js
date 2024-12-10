import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'

dotenv.config()

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function testProfilesTable() {
  try {
    console.log('Testing Supabase connection...')
    
    // Test profiles table existence
    console.log('\nChecking profiles table...')
    const { data: tables, error: tablesError } = await supabase
      .from('information_schema.tables')
      .select('table_name')
      .eq('table_schema', 'public')
      .eq('table_name', 'profiles')

    if (tablesError) {
      console.error('Error checking profiles table:', tablesError)
      return
    }

    if (!tables || tables.length === 0) {
      console.error('Profiles table does not exist!')
      return
    }

    // Test profiles table structure
    console.log('\nChecking profiles table structure...')
    const { data: columns, error: columnsError } = await supabase
      .from('information_schema.columns')
      .select('column_name, data_type, is_nullable')
      .eq('table_schema', 'public')
      .eq('table_name', 'profiles')

    if (columnsError) {
      console.error('Error checking profiles columns:', columnsError)
      return
    }

    console.log('\nColumns found:')
    columns.forEach(col => {
      console.log(`- ${col.column_name} (${col.data_type}, ${col.is_nullable === 'YES' ? 'nullable' : 'not null'})`)
    })

    // Verify required columns
    const requiredColumns = {
      id: 'uuid',
      first_name: 'character varying',
      last_name: 'character varying',
      email: 'character varying',
      created_at: 'timestamp with time zone',
      updated_at: 'timestamp with time zone'
    }

    const missingColumns = []
    for (const [colName, colType] of Object.entries(requiredColumns)) {
      const col = columns.find(c => c.column_name === colName)
      if (!col) {
        missingColumns.push(colName)
      } else if (col.data_type !== colType) {
        console.warn(`Column ${colName} has type ${col.data_type}, expected ${colType}`)
      }
    }

    if (missingColumns.length > 0) {
      console.error('\nMissing required columns:', missingColumns)
    } else {
      console.log('\nAll required columns present with correct types')
    }

    // Test RLS policies
    console.log('\nChecking RLS policies...')
    const { data: policies, error: policiesError } = await supabase
      .from('pg_policies')
      .select('*')
      .eq('tablename', 'profiles')

    if (policiesError) {
      console.error('Error checking RLS policies:', policiesError)
      return
    }

    if (!policies || policies.length === 0) {
      console.error('No RLS policies found for profiles table!')
    } else {
      console.log('RLS policies found:', policies.length)
      policies.forEach(policy => {
        console.log(`- ${policy.policyname}: ${policy.cmd} ${policy.qual}`)
      })
    }

  } catch (err) {
    console.error('Error testing profiles table:', err)
  }
}

testProfilesTable()