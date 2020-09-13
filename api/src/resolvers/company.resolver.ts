import { Resolver, Query, Mutation, Arg, Authorized, ID } from 'type-graphql';
import Company from '../entities/company.entity';
import { GraphQLLimitedString } from 'graphql-custom-types';

const GraphQLCompanyConstraint = new GraphQLLimitedString(3, 24);

@Resolver()
export class CompanyResolver {
  @Authorized()
  @Query(() => [Company])
  companies(): Promise<Company[]> {
    return Company.find();
  }

  @Authorized()
  @Mutation(() => Company)
  async createCompany(
    @Arg('name', () => GraphQLCompanyConstraint) name: string
  ): Promise<Company> {
    const company = Company.create({
      name
    });

    await company.save();
    return company;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteCompany(@Arg('id', () => ID) id: number): Promise<boolean> {
    const company = await Company.findOne({
      where: { id }
    });
    if (!company) throw new Error('Company not found!');

    await company.remove();
    return true;
  }

  @Authorized()
  @Query(() => Company)
  async company(@Arg('id', () => ID) id: number): Promise<Company | boolean> {
    const company = await Company.findOne({
      where: { id }
    });

    return company || false;
  }
}
