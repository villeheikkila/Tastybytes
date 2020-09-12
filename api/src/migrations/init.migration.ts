import { getRepository, MigrationInterface, QueryRunner } from 'typeorm';
import { SodaSeed } from '../seeds/sodas.seed';
import { AccountSeed } from '../seeds/accounts.seed';
import { CategoriesSeed } from '../seeds/categories.seed';
import { SubCategoriesSeed } from '../seeds/subcategories.seed';

// export class SeedPermissionsAndRoles1556357483084
//   implements MigrationInterface {
//   public async up(_: QueryRunner): Promise<any> {
//     const accounts = await getRepository('account').save(AccountSeed);
//     console.log('accounts: ', accounts);
//     const categories = await getRepository('category').save(CategoriesSeed);
//     const subcategories = await getRepository('subcategory').save(
//       SubCategoriesSeed
//     );

//     await getRepository('category').save(categories);

//     console.log('categories: ', categories);
//   }

//   public async down(_: QueryRunner): Promise<any> {
//     // do nothing
//   }
// }
