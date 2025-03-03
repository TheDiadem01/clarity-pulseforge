import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test project creation and management",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // Create project
    let block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'create-project', 
        [types.ascii("Test Project"), types.principal(deployer.address)],
        deployer.address
      )
    ]);
    block.receipts[0].result.expectOk().expectUint(1);
    
    // Add team member
    block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'add-team-member',
        [types.uint(1), types.principal(user1.address), types.ascii("developer")],
        deployer.address
      )
    ]);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Create milestone
    block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'create-milestone',
        [types.uint(1), types.ascii("First Release"), types.uint(1671148800)],
        user1.address
      )
    ]);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});

Clarinet.test({
  name: "Test access controls",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    const user2 = accounts.get('wallet_2')!;
    
    // Create project
    let block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'create-project',
        [types.ascii("Test Project"), types.principal(deployer.address)],
        deployer.address
      )
    ]);
    
    // Test unauthorized project creation
    block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'create-project',
        [types.ascii("Unauthorized"), types.principal(user1.address)],
        user1.address
      )
    ]);
    block.receipts[0].result.expectErr().expectUint(401);
    
    // Test unauthorized team member addition
    block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'add-team-member',
        [types.uint(1), types.principal(user2.address), types.ascii("developer")],
        user1.address
      )
    ]);
    block.receipts[0].result.expectErr().expectUint(401);
  }
});

Clarinet.test({
  name: "Test communication features",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    
    // Setup project and team
    let block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'create-project',
        [types.ascii("Test Project"), types.principal(deployer.address)],
        deployer.address
      ),
      Tx.contractCall('pulseforge', 'add-team-member',
        [types.uint(1), types.principal(user1.address), types.ascii("developer")],
        deployer.address
      )
    ]);
    
    // Post message
    block = chain.mineBlock([
      Tx.contractCall('pulseforge', 'post-message',
        [types.uint(1), types.ascii("Test message")],
        user1.address
      )
    ]);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});
