import { GraphQLError } from 'graphql';
import { Kind } from 'graphql/language';
import { GraphQLPassword, GraphQLCustomScalarType } from 'graphql-custom-types';

// Create custom types with constraints
const validatorCounter: { [key: string]: number } = {};
export class GraphQLValidatedString extends GraphQLCustomScalarType {
  constructor(name: string, minLength = 1, maxLength: number) {
    // Make sure that the typename remains unique
    if (!(name in validatorCounter)) validatorCounter[name] = 0;
    else validatorCounter[name]++;
    const suffix = validatorCounter[name] > 0 ? validatorCounter[name] : '';

    const description = maxLength
      ? `${name} has to be between ${minLength} and ${maxLength} characters long.`
      : `${name} has to be at least ${minLength} characters long.`;

    const validator = (astNode: any) => {
      if (astNode.kind !== Kind.STRING) {
        throw new GraphQLError(
          `${name} has to be a string, got a type of ${astNode.kind}`,
          [astNode]
        );
      }

      if (astNode.value.length < minLength) {
        throw new GraphQLError(
          `${name} has to be at least ${minLength} characters long`,
          [astNode]
        );
      }

      if (maxLength && astNode.value.length > maxLength) {
        throw new GraphQLError(
          `${name} can't be longer than ${maxLength} characters`,
          [astNode]
        );
      }

      return astNode.value;
    };

    super(`${name}${suffix}`, description, validator);
  }
}

export const GraphQLUsername = new GraphQLValidatedString('UserName', 3, 16);

export const GraphQLTreatName = new GraphQLValidatedString('TreatName', 3, 24);

export const GraphQLLimitedPassword = new GraphQLPassword(6);

export const GraphQLCategoryName = new GraphQLValidatedString(
  'CategoryName',
  3,
  16
);

export const GraphQLCompanyName = new GraphQLValidatedString(
  'CompanyName',
  3,
  24
);
export const GrapQLReviewText = new GraphQLValidatedString(
  'ReviewText',
  3,
  1024
);
