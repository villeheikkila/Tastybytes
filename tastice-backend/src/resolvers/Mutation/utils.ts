import { prisma } from '../../generated/prisma-client';

export const createIfNewCompany = async (name: string): Promise<string> => {
    const companyExists = await prisma.$exists.company({
        name,
    });

    const companyObject = companyExists
        ? await prisma.companies({
              where: { name },
          })
        : await prisma.createCompany({
              name: name.charAt(0).toUpperCase() + name.slice(1).toLowerCase(),
          });

    const company = companyObject[0] || companyObject;

    return company.id;
};
interface Id {
    id: string;
}

export const createIfNewSubCategories = async (subCategories: string[], categoryId: string): Promise<Id[]> => {
    const subCategoriesIds: Id[] = [];

    for (let i = 0; i < subCategories.length; i++) {
        const subCategoryExists = await prisma.$exists.subCategory({
            name: subCategories[i],
        });

        if (!subCategoryExists) {
            const res = await prisma.createSubCategory({
                category: { connect: { id: categoryId } },
                name: subCategories[i].charAt(0).toUpperCase() + subCategories[i].slice(1).toLowerCase(),
            });

            subCategoriesIds.push({ id: res.id });
        } else {
            const res = await prisma.subCategories({
                where: { name: subCategories[i] },
            });

            subCategoriesIds.push({ id: res[0].id });
        }
    }

    return subCategoriesIds;
};
