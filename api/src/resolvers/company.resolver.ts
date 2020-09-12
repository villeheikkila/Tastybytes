import { Resolver, Query, Mutation, Arg, Authorized } from 'type-graphql';
import Company from '../entities/company.entity';

@Resolver()
export class CompanyResolver {
  @Authorized()
  @Query(() => [Company])
  companies(): Promise<Company[]> {
    return Company.find({ relations: ['products'] });
  }

  @Authorized()
  @Mutation(() => Company)
  async createCompany(@Arg('name') name: string): Promise<Company> {
    const company = Company.create({
      name
    });

    await company.save();
    return company;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteCompany(@Arg('id') id: string): Promise<boolean> {
    const company = await Company.findOne({
      where: { id },
      relations: ['products']
    });
    if (!company) throw new Error('Company not found!');

    await company.remove();
    return true;
  }

  @Authorized()
  @Query(() => Company)
  async company(@Arg('id') id: number): Promise<Company | boolean> {
    const company = await Company.findOne({
      where: { id },
      relations: ['products']
    });

    return company || false;
  }
}
